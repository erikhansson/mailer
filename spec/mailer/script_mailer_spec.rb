# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'mailer/script_mailer'

describe "The ScriptMailer" do
  it "should load recipients and not include addresses already sent to" do
    mailer = ScriptMailer.new("#{fixture_dir}/recipients", "#{fixture_dir}/recipients.log", { :from => 'test@email.com', :subject => 'Subject' })
    mailer.recipients.should have(4).addresses
    mailer.recipients.should_not include('success@email.com')
  end
end
