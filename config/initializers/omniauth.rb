#debugger
require Rails.root.to_s+"/lib/nate.rb"

Rails.application.config.middleware.use OmniAuth::Builder do  
  #provider :nate, '57da071cfa829016b63fb10d9653947b04dfa0ba3','2bb2f4150d18a8ca4ebd304e08345369' 
  provider :nate, CYWORLD_KEY, CYWORLD_SECRET
end