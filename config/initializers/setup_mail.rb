### this is temporary email account
### once pumpl have a domain, this configs below must be changed

ActionMailer::Base.smtp_settings = {  
  :address              => "smtp.gmail.com",  
  :port                 => 587,  
  :domain               => "prawirasoft.com",  
  :user_name            => "pumpl.dev@prawirasoft.com",  
  :password             => "temporary",  
  :authentication       => :login,  
  :enable_starttls_auto => true  
}