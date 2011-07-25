require 'oa-oauth'
require 'nate'

module OmniAuth
  module Strategies
    # tell OmniAuth to load our strategy
    autoload :Nate, 'lib/nate'
  end
end