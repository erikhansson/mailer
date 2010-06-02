require 'mail'
require 'hpricot'
require 'tempfile'

require File.dirname(__FILE__) + "/fix_protocol"
require File.dirname(__FILE__) + "/mailer/options"
require File.dirname(__FILE__) + "/mailer/smtp_connection"
require File.dirname(__FILE__) + "/mailer/abstract_sender"
require File.dirname(__FILE__) + "/mailer/sender"

require File.dirname(__FILE__) + "/mailer/recipients"
require File.dirname(__FILE__) + "/mailer/logger"
require File.dirname(__FILE__) + "/mailer/builder"


class Hash
  def to_binding(object = Object.new)
    object.instance_eval("def binding_for(#{keys.join(",")}) binding end")
    object.binding_for(*values)
  end
end

module Mailer
  def self.send(mail, options = nil)
    SmtpConnection.new(options).open do |smtp|
      smtp.send_mail mail
    end
  end
end
