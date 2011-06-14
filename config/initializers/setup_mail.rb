ActionMailer::Base.smtp_settings = {
  :address              => 'smtp.gmail.com',
  :port                 => '25',
  :domain               => 'pumpl.com',
  :user_name            => 'hi@pumpl.com',
  :password             => 'snsd808!',
  :authentication       => 'plain',
  :enable_starttls_auto => true,
  :openssl_verify_mode  => OpenSSL::SSL::VERIFY_NONE,
}
