require 'net/smtp'


module Mailer
  
  class MailerError < RuntimeError; end
  class ConnectionNotOpenError < MailerError; end
  
    
  class SmtpConnection
    
    def self.auth_smtp_options(options = {})
      options.merge({
        :host => 'mail.authsmtp.com',
        :port => 2525,
        :authentication => :cram_md5
      })
    end
    
    
    attr_reader :settings
    
    def initialize(settings = nil)
      @settings = Options.smtp_options(settings)
      
      @settings.keys.each do |key|
        raise ArgumentError.new("invalid option, {"+key.to_s+" => "+@settings[key].to_s+"}") unless [
            :host, :port, :username, :password, :authentication, :domain, :max_connections
          ].include?(key)
      end
    end
    
    def open
      @open = true
      open_connection
      yield self
    ensure
      @open = false
      close_connection
    end
    
    def get_net_smtp_instance
      Net::SMTP.new settings[:host], settings[:port]
    end
    
    ##
    # Sends the mail to the SMTP server. Returns true if the mail was
    # sent successfully, if not it raises an error. If this happens, the
    # connection is closed, and no more mails can be sent without reopening
    # the connection.
    #
    def send_mail(mail)
      raise ConnectionNotOpenError unless @open
      
      @connection.sendmail(mail.to_s, mail.from[0], mail.destinations)
      true
    rescue StandardError => e
      close_connection
      raise e
    end
    
    private
    def open_connection
      @connection = get_net_smtp_instance
      @connection.start(
        settings[:domain], 
        settings[:username],
        settings[:password],
        settings[:authentication]
      )
    end
    
    def close_connection
      @connection.finish if @connection && @connection.started?
      @connection = @open = nil
    end
  end
  
end
