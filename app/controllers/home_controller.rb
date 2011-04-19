class HomeController < ApplicationController
  
  def index
    render :text => "Picsy"
  end 
  
  def welcome
    if current_user
      redirect_to my_path
    else
      redirect_to "/"
    end    
  end  
  
  def crawl_rss
    Scraping::RSS.crawl_all
    Item.delete_all_duplicated
    Item.calculate_score
    render :text => "Crawling process has been done, <a href='/'>Back</a>"
  end  
  
  ### abandon method below, it's no longer used
  def daoneday
    Item.crawl_and_save
    redirect_to "/"
  end 
  
  ### for testing scheduling purpose
  def run_scheduling
    if params[:show_time] == "yes"
      Setting.show_time 
    else
      Item.check_expired_items
    end
    render :text => "success"
  end    
end
