# -*- encoding : utf-8 -*-
class Setting < ActiveRecord::Base
  validates_presence_of :var, :value
  
  ### for testing purpose to determine whether scheduling is worked or not
  def self.show_time
    content = "#{Time.now} \n"
    open(Rails.root+"public/crawling_time.txt", "a") { |file| file.write(content)}
  end  
end
