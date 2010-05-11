# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Mailer::Recipients" do
  
  describe :load do
    before(:each) do
      Mailer::Recipients.set_blacklist(File.dirname(__FILE__) + "/../fixtures/blacklist.txt")
      @addresses = Mailer::Recipients.load(File.dirname(__FILE__) + "/../fixtures/recipients")
    end
    
    it "should load addresses from the given file" do
      @addresses.length.should == 5
      @addresses.should include('test@email.com')
      @addresses.should include('i_am_email@foobar.se')
      @addresses.should include('test@email.com')
    end
    
    it "should exclude addresses logged as successfully sent to" do
      @addresses.should_not include('success@email.com')
    end
    
    it "should exclude blacklisted addresses" do
      @addresses.should_not include('blacklisted@email.com')
    end
    
    it "should correclty handle swedish characters" do
      @addresses.should include('pär@sverige.nu')
    end
    
  end
  
end
