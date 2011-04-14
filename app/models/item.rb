class Item < ActiveRecord::Base
  has_and_belongs_to_many :categories
  belongs_to :item_type
  has_one :item_stat
  
  validates_presence_of :title, :url, :deal_price, :original_price, :begin_date, :finish_date
  
  cattr_reader :per_page
  @@per_page = ADMIN_LIMIT
  
  has_attached_file :image, :styles => { :medium => "200x125!"}
  
  before_create :assign_division, :assign_region
  before_save :determine_expired
  
  ## division would be assigned as item_type model, region would be assigned as category model
  attr_accessor :division, :region
    
  def true_image_url
    if self.picture_url.blank?
      self.image.url(:medium)
    else
      self.picture_url
    end    
  end  
  
  def discount
    rs = ((self.original_price.to_f - self.deal_price.to_f) / self.original_price.to_f) * 100
    return rs.two_digit_decimal
  end  
  
  def time_left
    rs_integer = (self.finish_date.to_time.to_f - Time.now.to_f).to_i
    if rs_integer < 0
      return self.finish_date.strftime("%B %d, %Y")
    else  
      days = (rs_integer/86400).to_i
    
      seconds_left = rs_integer - (days * 86400)
      hours = (seconds_left / 3600).to_i
    
      seconds_left = (rs_integer - (days * 86400)) - (hours * 3600)
      minutes = (seconds_left/60).to_i
 
      rs = ""
      rs << "#{days} 일, " if days > 0
      rs << "#{hours} 시간, " if hours > 0
      rs << "#{minutes} 분"
      return "남은시간: #{rs}"
    end  
  end  
  
  def Item.number_of_deals(options)
    
    time_now = Time.now
    cat_ids = Category.collect_parent_children_ids_by_name(options[:category_name]) unless options[:category_name].include?("All")
    
    if options[:category_name].include?("All") and options[:item_type_name].include?("All")
      return Item.count(:conditions => ["begin_date <= ? AND deal_status != ? AND is_hide = ?",time_now, DealStatus::EXPIRED, false])
    elsif options[:item_type_name].include?("All")
      return Item.count(:conditions => ["categories.id IN (?) AND begin_date <= ? AND deal_status != ? AND is_hide = ?", cat_ids,time_now, DealStatus::EXPIRED, false], :include => :categories) 
    elsif options[:category_name].include?("All")  
      return Item.count(:conditions => ["item_types.name IN (?) AND begin_date <= ? AND deal_status != ? AND is_hide = ?", options[:item_type_name],time_now, DealStatus::EXPIRED, false] ,:include => :item_type)
    else
      return Item.count(:conditions => ["((categories.id IN (?) AND item_types.name IN (?)) OR (none_status=? AND item_types.name IN (?))) AND begin_date <= ? AND deal_status != ? AND is_hide = ?",cat_ids, options[:item_type_name], true, options[:item_type_name],  time_now, DealStatus::EXPIRED, false], :include => [:item_type,:categories])   
    end
  end  
  
  
  def Item.filter(options)
    
    [:category_name,:item_type_name].each do |dt|
      options[dt].reject! {|value| value=="All" or value.blank?}
    end
    
    offset = ((options[:page] || 1).to_i - 1) * LIMIT
    cat_ids = Category.collect_parent_children_ids_by_name(options[:category_name]) unless options[:category_name].include?("All")
    time_now = Time.now
    order = "deal_status, score, sales_cnt, expired_timestamp,finish_date"
    
    Rails.logger.info "DEBUG FILTER OPTIONS #{options.inspect}"
    
    if options[:category_name].size == 0 and options[:item_type_name].size == 0
      Rails.logger.info "DEBUG FILTER 1st QUERY"
      return Item.all(:conditions => ["begin_date <= ? AND is_hide=?",time_now, false], :order => order, :limit => LIMIT, :offset => offset )
    elsif options[:category_name].size > 0 and options[:item_type_name].size == 0
      Rails.logger.info "DEBUG FILTER 2nd QUERY"
      return Item.find(:all,:conditions => ["categories.id IN (?) AND begin_date <= ? AND is_hide=?", cat_ids,time_now, false], :include => :categories,:order => order, :limit => LIMIT, :offset => offset) 
    elsif options[:category_name].size == 0 and options[:item_type_name].size > 0  
      Rails.logger.info "DEBUG FILTER 3rd QUERY"
      return Item.find(:all,:conditions => ["item_types.name IN (?) AND begin_date <= ? AND is_hide=?", options[:item_type_name],time_now, false] ,:include => :item_type, :order => order, :limit => LIMIT, :offset => offset)
    else
      Rails.logger.info "DEBUG FILTER 4th QUERY"
      return Item.find(:all,:conditions => ["((categories.id IN (?) AND item_types.name IN (?)) OR (none_status=? AND item_types.name IN (?))) AND begin_date <= ? AND is_hide=?",cat_ids, options[:item_type_name], true, options[:item_type_name],  time_now, false], :include => [:item_type,:categories], :order => order, :limit => LIMIT, :offset => offset)   
    end  
  end 
  
  def Item.mydeals(user, controller, page)
    offset = ((page || 1).to_i - 1) * LIMIT
    time_now = Time.now
    order = "deal_status, score, sales_cnt, expired_timestamp,finish_date"
    
    item_type_ids = ItemType.mine(user,controller).collect {|itype| itype.id}
    category_ids = Category.mine(user,controller).collect {|cat| cat.id}
    
    return Item.find(:all, :conditions => ["(item_type_id IN (?) OR categories.id IN (?)) AND begin_date <= ? AND is_hide=?", item_type_ids, category_ids, time_now, false],:include => :categories, :offset => offset, :limit => LIMIT, :order => order )
    
  end
    
  ### only use this method once in every day, for check expired individual item purpose use determine_expired method instead  
  def Item.check_expired_items
    time_now = Time.now
    date_now_str = Time.now.strftime("%Y-%m-%d")
    latest_check_expired = Setting.find_by_var("latest_check_expired")
    
    if latest_check_expired.nil? or latest_check_expired.value.gsub("-","").to_i <= date_now_str.gsub("-","").to_i
      
      #@eligible_items = Item.find(:all, :conditions => ["deal_status!= ?", DealStatus::EXPIRED])
      @eligible_items = Item.all ## for temporary, execute on first time only
      @eligible_items.each do |item|
        if item.finish_date < time_now
          item.update_attributes(:deal_status => DealStatus::EXPIRED,:expired_timestamp => (time_now - item.finish_date))  
        elsif item.max_sales_cnt.to_i > 0 and item.sales_cnt.to_i >= item.max_sales_cnt.to_i
          item.update_attributes(:deal_status => DealStatus::SOLD_OUT,:expired_timestamp => nil)  
        else  
          item.update_attributes(:deal_status => DealStatus::AVAILABLE,:expired_timestamp => nil)  
        end  
      end   
        
      if latest_check_expired.nil?
        Setting.create(:var => "latest_check_expired",:value => date_now_str)
      else
        latest_check_expired.update_attribute(:value,date_now_str)
      end    
    end  
  end  
  
  def deal_status_in_word
    if self.deal_status == DealStatus::AVAILABLE
      return "Available"
    elsif  self.deal_status == DealStatus::SOLD_OUT
      return "Sold Out"
    else
      return "Expired"
    end    
  end  
    
  ### ABANDON METHOD BELOW, IT'S NO LONGER USED
  def self.crawl_and_save
    result = Scraping::Daoneday.crawl
    result.each do |crawl_item|
      item = Item.new(crawl_item)
      item.save!
    end  
  end  
  ### END OF ABANDON
  
  def self.delete_all_duplicated
    sql = "SELECT min(id), rss_source || ' ' || url as unique_data FROM items GROUP BY unique_data HAVING count(*) >= 1"
    @items = Item.find_by_sql(sql)
    Item.delete_all(["id NOT in (?)", @items.collect {|it| it.min}]) if @items.size > 0
  end  
  
  def self.calculate_score
    ### delete expired item stat
    exp_ids = ItemStat.find(:all,:conditions => ["items.deal_status=?", DealStatus::EXPIRED],:include => :item ).collect {|ex| ex.id}
    ItemStat.destroy(exp_ids) if exp_ids.size > 0
    
    Item.find(:all,:conditions => ["items.deal_status < ?", DealStatus::EXPIRED], :order => "sales_cnt DESC").each_with_index do |item,idx|
      item_stat_hash = {:sales_ranking => idx+1, :revenue => item.deal_price * item.sales_cnt, :item_id => item.id}
      
      unless item.item_stat
        ItemStat.create(item_stat_hash)
      else
        item.item_stat.update_attributes(item_stat_hash)
      end
      
    end  
    
    Item.find(:all,:conditions => ["items.deal_status < ?", DealStatus::EXPIRED], :order => "item_stats.revenue DESC", :include => :item_stat).each_with_index do |item,idx|
    
      unless item.item_stat
        ItemStat.create(:revenue_ranking => idx+1, :item_id => item.id) 
      else
        item.item_stat.update_attributes(:revenue_ranking => idx + 1, :item_id => item.id)
      end  
      #Rails.logger.info "sales ranking #{item.item_stat.sales_ranking}"
      item.score = ((idx+1) + item.item_stat.sales_ranking) / 2.00
      item.save
    end
 
  end  
  
  protected
  def determine_expired
    time_now = Time.now
    if self.finish_date && self.finish_date < time_now
      self.deal_status = DealStatus::EXPIRED
      self.expired_timestamp = time_now - self.finish_date
      self.sales_cnt = 0
      self.max_sales_cnt = 0
    elsif self.max_sales_cnt.to_i > 0 and self.sales_cnt.to_i >= self.max_sales_cnt.to_i
      self.deal_status = DealStatus::SOLD_OUT
      self.expired_timestamp = nil
    else
      self.deal_status = DealStatus::AVAILABLE  
      self.expired_timestamp = nil
    end 
    return true 
  end  
  
  ### division will go to item_types table which is in UI. it's called Category
  def assign_division
    division_hash = {
      "맛집" =>  "맛집.카페",
      "카페/술집" => "맛집.카페",
      "카페" => "맛집.카페",
      "술집" => "술집.와인",
      "공연/전시" => "공연.전시",
      "공연" => "공연.전시",
      "전시" => "공연.전시",
      "레저/취미" => "레저.취미",
      "레저" => "레저.취미",
      "취미" => "레저.취미",
      "뷰티/생활" => "뷰티.생활",
      "뷰티" => "뷰티.생활",
      "생활" => "뷰티.생활",
      "여행" => "여행"
    }
    Rails.logger.info "DEBUG division #{self.division}"
    division_hash.each do |key,value|
      if key == self.division
        self.item_type = ItemType.find_by_name(value) || ItemType.new(:name => value)
        break  
      end  
    end  
     
    ### assign item type default
    self.item_type = ItemType.find_by_name("기타") || ItemType.create(:name => "기타") if self.item_type.blank?
  end
  
  ### region will go to categories table which is in UI, it's called Location
  def assign_region
    region_hash = {
      "강남" => "서울, 강남",
      "강북" => "서울, 강북",
      "경기" => "경기도",
      "인천" => "인천",
      "대전" => "충청도",
      "대구" => "경상도, 대구",
      "부산" => "경상도, 부산",
      "광주" => "전라도"
    }
    
    Rails.logger.info "DEBUG region #{self.region}"
    
    region_hash.each do |key,value|
      cats = []
      if key == self.region
        value.split(", ").each do |ind_val|
          cats << Category.find_by_name(ind_val) || Category.new(:name => value)
        end  
        self.categories = cats
      end  
    end  
    
    if self.categories.size == 0 and self.region == "해외"
      self.categories = []
    elsif self.categories.size == 0
      cat = Category.find_by_name("기타") || Category.new(:name => "기타")
      self.categories = [cat]
    end    
  end    
     
end
