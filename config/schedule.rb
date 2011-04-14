# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
0.upto(2) do |i|
  the_minute = ((i*20) + 1).to_s 
  the_minute = "0#{the_minute}" if the_minute.size == 1
    
  every 1.hour, :at => "12:#{the_minute} am" do
    ## crawling
    runner "Scraping::RSS.crawl_all"
  end
end  

every 1.day, :at => "12:01 am" do
  ## check expired items
  runner "Item.check_expired_items"
end  

  

