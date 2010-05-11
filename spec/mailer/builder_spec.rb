# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Mailer::Builder" do
  
  it "should take a directory with an email when initialized" do
    builder = Mailer::Builder.new(fixture_dir + "/email")
    lambda do
      Mailer::Builder.new(fixture_dir + "/foobar")
    end.should raise_error
  end
  
  context "when initialized with a valid html email with an attached image and a text alternative" do
    before(:each) do
      @builder = Mailer::Builder.new(fixture_dir + "/email")
      @mail = @builder.build :from => 'erik@bits2life.com', :to => 'erik@bits2life.com', :subject => 'Thank you'
    end
    
    it "should have created a multipart/related message" do
      @mail.parts[0].content_type.should include('multipart/related')
      @mail.parts[0].parts[0].content_type.should include('multipart/alternative')
    end
    
    it "should have included the plaintext version of the mail" do
      @mail.parts[0].parts[1].content_type.should include('image/png')
      @mail.parts[0].parts[1].content_type.should include('filename=headline.png')
    end
    
    it "should have included the html version of the mail" do
      @mail.parts[0].parts[0].parts[1].content_type.should == 'text/html'
    end
    
    it "should have automagically linked the image to an inline attachment" do
      @mail.parts[0].parts[0].parts[0].content_type.should == 'text/plain'
    end
    
  end

  it "should allow templates in these emails, and feed these templates with information"
  
end
