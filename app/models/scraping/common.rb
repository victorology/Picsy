module Scraping
  module Common
    def grab_content(path)
      ## if mechanize failed, use httpclient instead
      begin
        agent = Mechanize.new
        page = agent.get(path)
        content = page.body
      rescue Zlib::DataError
        clnt = HTTPClient.new
        content = clnt.get_content(path)
      end    
      
      return content
    end  
  
    ### pre value
    def hardcode_hash
      result_hash = {}
      result_hash[:begin_date] = Time.now.advance(:days => - (rand(25) + 5))
      return result_hash
    end 
    
    def url_escape(url)
      URI.escape(url.strip).gsub("[","%5b").gsub("]","%5d")
    end  
    
    def image_processing(item,image_url)
      Rails.logger.info "DEBUG escaping url #{url_escape(image_url)}"
      
      #content = HTTPClient.new.get_content url_escape(image_url)
      crawl_dir = "#{Rails.root}/public/images/crawl"
      full_path = "#{crawl_dir}/#{File.basename(image_url)}"
      
      cu = Curl::Easy.perform url_escape(image_url)
      Dir.mkdir(crawl_dir) unless File.exist?(crawl_dir)
      open(full_path, "wb") { |file| file.write(cu.body_str)}
      
      rs = item.update_attribute(:image, File.open(full_path))
      File.delete(full_path)
      
      return rs
    end 
    
    ### attempt to fetch the images untill [max_count] times
    def image_processing_recursive(item,max_count, idx = 1)
      msg = {}
      @complete_error = ""
      Rails.logger.info "DEBUG #{idx.ordinalize} attempt to grab image #{item.picture_url}"

      begin
        rs = image_processing(item,item.picture_url) 
      rescue Exception => e 
        @complete_error = "image processing error #{e.message} while access #{item.picture_url} on item ##{item.id}, we recommend you localize this item again or upload the image manually"
        Rails.logger.info "DEBUG #{@complete_error}"
        rs = false
      end

      if rs == true
        item.reload
        item.update_attribute(:picture_url,nil)
        msg[:notice] = "images for item ##{item.id} has been successfully localized <br />"
      else
        if idx <= max_count
          idx+=1
          image_processing_recursive(item,max_count, idx)
        else  
          msg[:alert] = @complete_error 
        end   
      end  
      return msg      
    end   
    
    def create_item(product,product_tag)
      Rails.logger.info "DEBUG PRODUCT #{product.inspect}"
      
      begin
        #item = Item.find_by_url_and_rss_source(product[:url],product[:rss_source])
        duplicated_items = Item.find(:all, :conditions => {:url => product[:url],:rss_source => product[:rss_source]})
        item = duplicated_items[0]
        
        ## delete duplicated items
        if duplicated_items.size > 1
          deleted_ids = duplicated_items.collect {|it| it.id}.reject {|the_id| the_id == item.id}
          Rails.logger.info "DEBUG DELETE DUPLICATED ITEMS #{deleted_ids.join(', ')}"
          Item.destroy(deleted_ids)  
        end   
        
        
        unless item
          product[:picture_url] = product[:image_url]
          item = Item.new(product.reject {|key,value| key.to_s == "image_url"})
  
          if item.save
            ### image processing     
            if CRAWL_IMAGES == true    
              msg = image_processing_recursive(item,3)
              return msg[:notice] && msg[:alert].blank? ? true : false
            else
              return true
            end    
          else        
            item_log "item isn't valid #{item.errors.full_messages.inspect}", product[:rss_source]
            return false
          end
        else
          
          ### update image
          image_path = Rails.root.to_s+"/public#{item.image(:medium).split('?')[0]}"
          
          if item.image_file_name.blank? or File.exist?(image_path) == false and CRAWL_IMAGES == true
            Rails.logger.info " DEBUG update and re-grab image for ##{item.id}"
            product[:picture_url] = product[:image_url]
            item.update_attributes(product.reject {|key,value| key.to_s == "image_url"})
            msg = image_processing_recursive(item,3)
            return msg[:notice] && msg[:alert].blank? ? true : false 
          else
            Rails.logger.info " DEBUG update sales cnt for ##{item.id}"
            item.update_attributes(:sales_cnt => product[:sales_cnt], :max_sales_cnt => product[:max_sales_cnt])    
          end
        end      
        

      rescue ActiveRecord::StatementInvalid
        item_log "Can't insert items, invalid character for #{product.inspect}", product[:rss_source]
      rescue HTTPClient::ReceiveTimeoutError  
        item_log "Timeout while grabing item", product[:rss_source]
      rescue Timeout::Error
        item_log "Timeout while grabing item", product[:rss_source]  
      end
    end  
    
    def item_log(msg, source)
      Rails.logger.info "DEBUG #{msg}, source #{source}"
      msg = "PGError: ERROR:  invalid byte sequence for encoding UTF8" if msg.include?("invalid byte sequence")
      ItemLog.create(:reason => msg, :source => source) if ENABLE_ITEM_LOG == true
    end  
    
  end 
end  