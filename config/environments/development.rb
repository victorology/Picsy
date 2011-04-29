Picsy::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  
  # host
  config.action_mailer.default_url_options = { :host => 'localhost:3300' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
end

## TWITTER CONFIGURATION
TWITTER_CONSUMER_KEY = "OSfFsclVxhB1nfIzEVkBkg"
TWITTER_CONSUMER_SECRET = "35EHXmEmUjwiSgX3k6K1EFU06DAijfKXlZlNwTJAqJo"
TWITTER_CONFIRM_PATH = "twitter/confirm"

## FACEBOOK CONFIGURATION
FACEBOOK_APPLICATION_ID = "175899045777547"
FACEBOOK_APPLICATION_SECRET = "dfe3b5b2f167e7369c46efd580b9f8aa"
FACEBOOK_CALLBACK = "http://localpumpl.com/"

## TUMBLR CONFIGURATION
TUMBLR_SECRET = "picsy_dev"
TUMBLR_SALT = "Op9cLyhggHtP8oYAC+DdPcRDLmrh0cGo7gdAB5dCQ=2Kx"

## this api is created by aditya, it's for temporary purpose
## for the real API key need to ask to Victor
ME2DAY_KEY = "85700c4d74697b45cff0b499c09c253e"

