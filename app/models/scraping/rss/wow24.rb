module Scraping
  module RSS
    class Wow24
      include Scraping::Common
      
      TARGET_PATH = []            
      
      def self.crawl_and_save(custom_paths=[])
        require 'open-uri'
        
        results = []
        product = {}
        
        paths = (custom_paths.size > 0) ? custom_paths : TARGET_PATH
        paths.each do |path|
          begin
            wow24 = Wow24.new 
          
            content = CRAWL_METHOD=="online" ? wow24.grab_content(path) : File.open("#{Rails.root}/doc/wow24_example.xml")
          
            doc = Nokogiri::XML content
            doc.xpath("//deals//item").each do |product_tag|
              ### merged hardcode hash
              product.merge!(wow24.hardcode_hash)
              ### end of merged
                
              product[:title] = product_tag.xpath("title")[0].content
              product[:original_price] = product_tag.xpath("original")[0].content
              product[:deal_price] = product_tag.xpath("price")[0].content
                
              product[:finish_date] = wow24.time_parsing(product_tag.xpath("end_at")[0].content)
              product[:begin_date] = wow24.time_parsing(product_tag.xpath("start_at")[0].content)
              product[:url] = product_tag.xpath("url")[0].content
              product[:image_url] = product_tag.xpath("image")[0].content     
              product[:rss_source] = path
              product[:rss_kind] = "Wow24"
              
              wow24.create_item(product,product_tag)    
  
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
      
      def time_parsing(the_time)
        month = the_time.split("월")[0]
        day_hrs = the_time.split("일") 
        day = day_hrs[0].split("월")[1] 
        
        day = "30" if day=="0"
          
        return "#{Time.now.strftime('%Y')}-#{month}-#{day} #{day_hrs[1]}"
      end  
        
    end
  end
end