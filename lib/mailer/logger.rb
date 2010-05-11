module Mailer
  
  class Logger
    
    attr_accessor :sent, :failed
    
    def initialize(filename)
      if File.exists?(filename)
        @file = File.open(filename, 'r+:UTF-8')
        @sent, @failed = Logger.read_log @file
      else
        @file = File.open(filename, 'w:UTF-8')
        @sent, @failed = [], []
      end
      
      if block_given?
        yield self
        close
        @file = nil
      end
    end
    
    def close
      @file.close
      @file = nil
    end
    
    def success(address)
      @file.puts "[SUCCESS/#{address}]"
      @sent << address
    end
    
    def failure(address)
      @file.puts "[FAILURE/#{address}]"
      @failed << address
    end

    def self.read_log(file)
      sent, failed = [], []
      while line = file.gets
        line.strip!
        if line =~ /\[SUCCESS\/(.+)\]/
          sent << $1
        elsif line =~ /\[FAILURE\/(.+)\]/
          failed << $1
        end
      end
      [sent, failed]
    end
    
  end
  
end
