# encoding: utf-8

module Mailer
  class Builder
    
    def initialize(path)
      raise "Not a directory" unless File.directory?(path)
      @path = path
    end
    
    def build(options)
      result = nil
      Dir.chdir @path do
        result = Mail.new do
          from options[:from]
          to options[:to]
          subject options[:subject]

          part :content_type => 'multipart/related' do |related|
            related.part :content_type => 'multipart/alternative' do |alternative|
              alternative.part :content_type => 'text/plain', :body => File.read('mail.txt')
              alternative.part :content_type => 'text/html', :body => nil
            end

            doc = Hpricot(File.read('mail.html'))
            images = doc / 'img'
            parts = Hash.new
            
            images.each do |img|
              if parts[img.attributes['src']]
                img.attributes['src'] = parts[img.attributes['src']].content_id
              else
                related.add_file img.attributes['src']
                parts[img.attributes['src']] = related.parts[-1]
                related.parts[-1].encoded
              end
            end
            related.parts[0].parts[1].body = doc.to_s
          end
        end
        
        result
      end
      
    end
    
  end
end
