module Scraping
  module RSS
    def self.crawl_all
      ItemLog.destroy_all if ENABLE_ITEM_LOG == true
      Scraping::RSS::Daoneday.crawl_and_save
      Scraping::RSS::Couponmoa.crawl_and_save
      Scraping::RSS::Wow24.crawl_and_save
    end  
  end  
end  