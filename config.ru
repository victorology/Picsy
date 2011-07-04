# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'omniauth'

use OmniAuth::Strategies::Nate, CYWORLD_KEY, CYWORLD_SECRET
run Picsy::Application
