# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Picsy::Application.initialize!

## paperclip interpolation, it will be used when creaate custom link on the images
module Paperclip
  # This module contains all the methods that are available for interpolation
  # in paths and urls. To add your own (or override an existing one), you
  # can either open this module and define it, or call the
  # Paperclip.interpolates method.
  module Interpolations
    extend self
    
    # PATCHING PAPERCLIP
    # ADD ABILITY TO RETRIEVE another pattern
    def pattern_code attachment, style_name
      attachment.instance.pattern_code
    end
    
    def pattern_nickname attachment, style_name
      attachment.instance.pattern_nickname
    end
  end
end    
