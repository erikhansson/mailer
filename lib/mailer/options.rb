# encoding: utf-8

module Mailer
  class Options
    
    def self.smtp_options(options = nil)
      if options.is_a? Hash
        options
      else
        eval(File.read(options || File.expand_path("~/.config/smtp.rb")))
      end
    end
    
  end
end
