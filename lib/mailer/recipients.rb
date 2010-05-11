
module Mailer
  module Recipients
    
    @@blacklist_path = File.expand_path("~/.config/blacklist.txt")
    
    def self.load(filename)
      addresses = read_addresses filename
      blacklist = read_addresses @@blacklist_path
      
      addresses - blacklist
    end
    
    def self.read_addresses(filename)
      result = []
      File.open(filename, 'r:UTF-8') do |file|
        while line = file.gets
          line.strip!
          if line =~ /.+@.+\..+/
            result << line
          else
            raise "Invalid email address #{line}" unless line.blank?
          end
        end
      end
      result
    end
    
    def self.set_blacklist(path)
      @@blacklist_path = path
    end
    
  end
end
