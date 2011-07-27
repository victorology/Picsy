# coding: utf-8
class InviteMailer < ActionMailer::Base
  default :from => "hi@pumpl.com"
  
  def sharing_email(invite, referal_url)
    @referal_url = referal_url
    mail(:to => invite.email, :subject => "PUMPL에 가입해주셔서 감사합니다!")
  end
end
