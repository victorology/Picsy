module Scraping
  module RSS
    class Couponmoa
      include Scraping::Common
      
      TARGET_PATH = []            
      
      def self.crawl_and_save(custom_paths = [])
        require 'open-uri'
        
        results = []
        product = {}
        
        paths = (custom_paths.size > 0) ? custom_paths : TARGET_PATH
        paths.each do |path|
          begin
            couponmoa = Couponmoa.new 
            doc = Nokogiri::XML couponmoa.grab_content(path)
            doc.xpath("//coupon_feed").each do |product_tag|
              ### merged hardcode hash
              product.merge!(couponmoa.hardcode_hash)
              ### end of merged
                
              product[:title] = product_tag.xpath("deals//deal//title")[0].content.gsub("<![CDATA[","").gsub("]]>","").strip
              product[:original_price] = product_tag.xpath("deals//deal//original")[0].content.gsub(",","").gsub("원","").gsub("�썝","").strip 
              product[:deal_price] = product_tag.xpath("deals//deal//price")[0].content.gsub(",","").gsub("원","").gsub("�썝","").strip 
              product[:finish_date] = product_tag.xpath("deals//deal//end_at")[0].content.gsub("<![CDATA[","").gsub("]]>","").strip
              product[:begin_date] = product_tag.xpath("deals//deal//start_at")[0].content.gsub("<![CDATA[","").gsub("]]>","").strip
              product[:url] = product_tag.xpath("deals//deal//url")[0].content.gsub("<![CDATA[","").gsub("]]>","").strip         
              product[:image_url] = product_tag.xpath("deals//deal//images//image")[0].content.gsub("<![CDATA[","").gsub("]]>","").strip
              product[:rss_source] = path
              product[:rss_kind] = "Couponmoa"
              
              couponmoa.create_item(product,product_tag)            
            end  
          rescue Errno::ETIMEDOUT
            Rails.logger.info "timeout while access #{path}"   
          rescue Zlib::DataError
            Rails.logger.info "zlib error while access #{path}"
          rescue Exception => e   
            Rails.logger.info "#{e.message} error while access #{path} "     
          end
        end
        return true
      end
        
    end
  end
end