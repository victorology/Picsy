module Scraping
  module HTML
    class Daoneday
   
  def self.crawl
    @result = []
    if CRAWL_METHOD == "online"
      agent = Mechanize.new
      page = agent.get("http://www.daoneday.com/main.php")
      content = page.body
    else
      content = File.open("#{Rails.root}/doc/daoneday_example.html")
    end    
    
    doc = Nokogiri::HTML(content)
    
    basic_result = doc.xpath("//div//table//tr//td//table//tr//td//div//table//tr//td//table//tr//td")
    result_hash = {}
    0.upto(basic_result.size - 1) do |i|
      result_hash = {:title => basic_result[i].text} if i % 35 == 0
      
      if i!=0 and (i - 17) % 35 == 0
        price = basic_result[i].text 
        result_hash.merge!(:deal_price => price.split("원")[0].gsub(",",""),:original_price => price.split("할인")[1].gsub(",","").strip)
      end   
      
      if i!=0 and (i - 26) % 35 == 0
        hrs = basic_result[i].text + basic_result[i+1].text + basic_result[i+2].text
        mnt = basic_result[i+4].text + basic_result[i+5].text
        
        result_hash.merge!(:finish_date => Time.now.advance(:hours => hrs.to_i, :minutes => mnt.to_i))               
      end
      
      ### VALUE BELOW IS HARDCODED
      ### TO AVOID VALIDATION FAILED ON ITEM OBJECT
      result_hash[:item_type_id] = ItemType.all.first.id
      result_hash[:category_ids] = [Category.all.first.id]
      result_hash[:url] = "http://www.daoneday.com/"
      result_hash[:begin_date] = Time.now.advance(:days => -30)
      ### END OF HARDCODED
        
      if i % 35 == 0 and i != 0
        @result << result_hash
      end   
    end
    
  
    return @result 
      end  
    end  
  end
end