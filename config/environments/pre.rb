DealAggregator::Application.configure do
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
  config.action_mailer.default_url_options = { :host => '184.106.216.249' }
end

## TWITTER CONFIGURATION
TWITTER_CONSUMER_KEY = "0O5TGggMyrXMfl8BxPrw"
TWITTER_CONSUMER_SECRET = "qLX4ACmEJIw8NAqzsLbYqBX78JhTJLQlLiKluUhc"
TWITTER_CONFIRM_PATH = "twitter/confirm"

## FACEBOOK CONFIGURATION
FACEBOOK_APPLICATION_ID = "125869140816410"
FACEBOOK_APPLICATION_SECRET = "a9054719000c05e765290ab9722c8eb5"
FACEBOOK_CALLBACK = "http://pre.pumpl.com/"

## this api is created by aditya, it's for temporary purpose
## for the real API key need to ask to Victor
ME2DAY_KEY = "85700c4d74697b45cff0b499c09c253e"

