Picsy::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  # host
  config.action_mailer.default_url_options = { :host => 'www.pumpl.com' }
end

## TWITTER CONFIGURATION
#TWITTER_CONSUMER_KEY = "bY8wsdv1eUhjqsE7MqWrg"
#TWITTER_CONSUMER_SECRET = "4ErHYfvbRdXFQHRmYwL7dtrtoBc5ZJeZ6ha3tnRX4"

TWITTER_CONSUMER_KEY = "h5x6RNCZCzf5S9PByqDy8A"
TWITTER_CONSUMER_SECRET = "6AlzuEks5qen27wzlGZGnjEyK8u1I2tOF8aql7zRM"
TWITTER_CONFIRM_PATH = "twitter/confirm"

## FACEBOOK CONFIGURATION  

## OLD CONFIGS
#FACEBOOK_APPLICATION_ID = "179071018781407"
#FACEBOOK_APPLICATION_SECRET = "d0759a215b3f255bbe1b3b0172218613"

FACEBOOK_CALLBACK = "http://www.pumpl.com/"
FACEBOOK_APPLICATION_ID = "170977086255854"
FACEBOOK_APPLICATION_SECRET = "f0a6ae80af084bb3f25fde7aa3d2d72e"

## TUMBLR CONFIGURATION
TUMBLR_SECRET = "picsy_prod"
TUMBLR_SALT = "phKYU0cGo7gdAB5djukKxOp1cLyhggHtP8oYACLO7nns"

## ME2DAY config
ME2DAY_KEY = "2a8512295365b1fe59b9ecc691c4fcb1"

