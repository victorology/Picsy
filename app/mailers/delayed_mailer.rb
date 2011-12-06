# coding: utf-8
class DelayedMailer < ActionMailer::Base
  default :from => "hi@pumpl.com"
  
  def send_log(message)
    @message = message
    mail(:to => "aditya.jamop@gmail.com", :subject => "PUMPL Error Log")
  end
end
