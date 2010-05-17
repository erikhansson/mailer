
module BulkMail
  
  class Sender
    include AbstractSender
    
    attr_accessor :smtp_options
    
    def initialize(settings = nil)
      @smtp_options = if settings.is_a? Hash
        settings
      else
        eval(File.read(settings || File.expand_path("~/.config/smtp.rb")))
      end
      @max_connections = @smtp_options.delete(:max_connections) || 4
    end
    
    # process = self.instance_method(:process)
    def process
      super @max_connections
    end
  end
  
end
