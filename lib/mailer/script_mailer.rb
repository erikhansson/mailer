class ScriptMailer < BulkMail::Sender
  
  attr_accessor :recipients
  
  def initialize(recipients_path, log_path, config)
    super(nil)
    
    @config = config
    @recipients = Mailer::Recipients.load(recipients_path).uniq
    @logger = Mailer::Logger.new log_path

    if @logger
      @recipients -= @logger.sent 
      @recipients -= @logger.failed
    end
    
    puts "Preparing emails"
    puts "#{@recipients.length} recipients found"
    puts "---"
  end
  
  def next_mail
    if to = @recipients.pop
      builder.build(@config.merge(:to => to)).tap do |mail|
        mail.instance_variable_set('@original_to', to)
      end
    end
  end
  
  def builder
    @builder ||= Mailer::Builder.new 'mail'
  end
  
  def success(mail)
    to = mail.instance_variable_get('@original_to')
    puts "[SUCCESS/#{to}]"
    @logger.success to
  end
  
  def failure(mail)
    to = mail.instance_variable_get('@original_to')
    puts ["FAILURE/#{to}"]
    @logger.failure to
  end
  
end
