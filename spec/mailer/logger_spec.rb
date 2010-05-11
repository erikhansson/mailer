# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Mailer::Logger" do
  
  context "created without a preexisting file" do
    before(:each) do
      @logger = Mailer::Logger.new(File.dirname(__FILE__) + "/../fixtures/nothere.log")
    end
    
    it "should have an empty sent array" do
      @logger.sent.should == []
    end
    
    it "should have an empty failed array" do
      @logger.failed.should == []
    end
    
    after(:each) do
      File.delete(fixture_dir + "/nothere.log")
    end
  end
  
  context "with a new logfile, after logging two successes" do
    before(:each) do
      @logger = Mailer::Logger.new(fixture_dir + 'twolines.log')
      @logger.success 'test@email.com'
      @logger.success 'again@email.com'
    end
    
    after(:each) do
      File.delete(fixture_dir + 'twolines.log')
    end

    it "should have two addresses in sent" do
      @logger.sent.should have(2).addresses
    end
    
    it "should have saved two lines in the logfile" do
      @logger.close
      
      read_log = Mailer::Logger.new(fixture_dir + 'twolines.log')
      read_log.sent.should have(2).addresses
    end
    
    it "should correctly append further logging to the logfile" do
      @logger.close
      
      @logger = Mailer::Logger.new(fixture_dir + 'twolines.log')
      @logger.failure 'foobar@email.com'
      @logger.close
      
      @logger = Mailer::Logger.new(fixture_dir + 'twolines.log')
      @logger.sent.should have(2).addresses
      @logger.failed.should have(1).address
    end
  end
  
end
