# encoding: utf-8

module Mailer
  class Builder
    
    def initialize(path)
      raise "Not a directory" unless File.directory?(path)
      @path = path
    end
    
    def build(options)
      result = nil
      builder = self
      Dir.chdir @path do
        result = Mail.new do
          from options[:from]
          to options[:to]
          subject options[:subject]

          part :content_type => 'multipart/related' do |related|
            related.part :content_type => 'multipart/alternative' do |alternative|
              alternative.part :content_type => 'text/plain', :body => builder.read_file_or_template('mail.txt', options[:variables])
              alternative.part :content_type => 'text/html', :body => nil
            end

            doc = Hpricot(builder.read_file_or_template('mail.html', options[:variables]))

            images = doc / 'img'
            parts = Hash.new
            
            images.each do |img|
              unless parts[img.attributes['src']]
                related.add_file img.attributes['src']
                parts[img.attributes['src']] = related.parts[-1]
                related.parts[-1].encoded
              end
              img.attributes['src'] = "cid:#{parts[img.attributes['src']].content_id[1...-1]}"
            end
            related.parts[0].parts[1].content_type ['text', 'html', { 'charset' => 'UTF-8' }]
            related.parts[0].parts[1].body = doc.to_s
          end
        end
        
        result
      end
    end
    
    def read_file_or_template(filename, variables)
      variables ||= {}
      if File.exists?(filename)
        File.read filename
      elsif File.exists?("#{filename}.erb")
        template = ERB.new File.read("#{filename}.erb")
        template.result(variables.to_binding)
      end
    end
    
  end
end
