# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mailer do
  
  describe :send do
    before(:each) do
      @mail = mock('email')
      @smtp = mock('smtp connection').as_null_object
      @smtp.should_receive(:open).and_yield(@smtp)
      @options = { :some => :options }
    end
    
    it "should send the supplied email" do
      @smtp.should_receive(:send_mail).with(@mail)
      Mailer::SmtpConnection.should_receive(:new).with(@options).and_return @smtp
      
      Mailer.send @mail, @options
    end
    
    it "should use the default settings if none are provided" do
      Mailer::SmtpConnection.should_receive(:new).with(nil).and_return @smtp
      Mailer.send @mail
    end
  end
  
end
