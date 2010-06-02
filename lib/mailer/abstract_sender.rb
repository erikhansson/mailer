
module Mailer
  
  # Include Mailer to provide a bulk mailer implementation. Basically,
  # :next_mail should return a mail instance to send, :success(mail) and 
  # :failure(mail) should log progress (or whatever). Further :smtp_options
  # should return the options to initialize SmtpConnections for the mailer
  # threads.
  module AbstractSender

    # Creates the SmtpConnection instance. Simply creates a new instance
    # with the options found in :smtp_options.
    def get_smtp_connection
      SmtpConnection.new smtp_options
    end
    
    # Spawns tcount threads, all of which pulls mails from next_mail, sends them 
    # to an SmtpConnection and calls success(mail) for as long as next_mail returns
    # anything but nil. If the sending fails, failure(mail) is called instead of
    # success(mail), the SmptConnection is dropped and the thread is paused for 
    # a few seconds. Then a new connection is made and the sending is resumed.
    #
    # All calls to next_mail, success and failure are synchronized on a single
    # lock, so you can likely safely just provide a trivial queue to create and
    # log the messages.
    #
    # The SmtpConnection instances are created using the options found in
    # :smtp_options. Make sure this property is set properly before calling :process.
    def process(tcount = 4)
      threads = []
      mutex = Mutex.new
      
      tcount.times do |n|
        threads << Thread.new(n) do |tid|
          process_mail tid, mutex
        end
      end
      
      threads.each { |thr| thr.join }
    end
    
    private
    
    # Sends mail for as long as there are mail available to send.
    def process_mail(tid, mutex)
      while mail = mutex.synchronize { next_mail }
        begin
          get_smtp_connection.open do |c|
            c.send_mail mail
            mutex.synchronize { success mail }
            
            while mail = mutex.synchronize { next_mail }
              c.send_mail mail
              mutex.synchronize { success mail }
            end
          end
        rescue StandardError => e
          mutex.synchronize { failure mail }
          sleep 3
        end
      end
    end
    
    # Default implementation. Logs success to stdout.
    def success(mail)
      puts "[SUCCESS/#{mail.to[0]}]"
    end
    
    # Default implementation. Logs failure to stdout.
    def failure(mail)
      puts "[FAILURE/#{mail.to[0]}]"
    end
    
  end
end
