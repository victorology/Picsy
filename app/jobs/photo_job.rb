class PhotoJob < Struct.new(:photo_id, :photo_hash)  
  include ActionView::Helpers::TextHelper

  def perform  
    @photo = Photo.find(photo_id)
    
    if @photo.user.facebook_connected? == true and @photo.post_to_facebook_wall == "yes"
      clnt = HTTPClient.new

      body = {:access_token => @photo.user.facebook_token, :link => photo_hash[:page_url], 
              :picture => photo_hash[:original_url], :name => @photo.title} 
      response = clnt.post("https://graph.facebook.com/#{@photo.user.facebook_id}/feed", body)

      fbid = JSON.parse(response.content)["id"].split("_")[1]
      id = JSON.parse(response.content)["id"].split("_")[0]
      @photo.update_attribute(:fb_wall_url, "http://facebook.com/permalink.php?story_fbid=#{fbid}&id=#{id}")     
    end

    if @photo.user.twitter_connected? == true and @photo.post_to_twitter == "yes"
      client = TwitterOAuth::Client.new(
                :consumer_key => TWITTER_CONSUMER_KEY,
                :consumer_secret => TWITTER_CONSUMER_SECRET,
                :token => @photo.user.twitter_token, 
                :secret => @photo.user.twitter_secret
               )

      client.update("#{truncate(@photo.title, :length => 120)} #{photo_hash[:shortened_url]}")  
    end

    if @photo.user.me2day_connected? == true and @photo.post_to_me2day == "yes"
      @client = Me2day::Client.new(
        :user_id => @photo.user.me2day_id, :user_key => @photo.user.me2day_key, :app_key => ME2DAY_KEY
      )      

      if JSON.parse(@client.noop)["code"].to_s == "0" #"성공했습니다."
        clnt = HTTPClient.new
              
        File.open(Rails.root.to_s+"/public"+@photo.image.url.split("?")[0]) do |file|
          body = { 
            'content_type' => "photo",
            'attachment' => file,  
            'post[body]' => "#{truncate(@photo.title, :length => 120)} #{photo_hash[:shortened_url]}",
            'uid'=> @photo.user.me2day_id,
            'ukey' => u_key(@photo.user.me2day_key)
          }
                
          post_uri = "http://me2day.net/api/create_post/#{@photo.user.me2day_id}.json"
          result = clnt.post(post_uri, body, 'me2_application_key' => ME2DAY_KEY)
          Rails.logger.info "POST RESULT #{result.body.inspect}"
        end
=begin              
        Rails.logger.info "ME2DAY NICKNAME #{@photo.user.me2day_nickname} \n"
              
        Rails.logger.info "STARTING TO GET POSTs"
              
        posts = @client.get_posts(@photo.user.me2day_id)
        Rails.logger.info "GRAB POSTS #{posts.inspect} \n"
              
        photo_path = Rails.root.to_s+"/public"+@photo.image.url.split("?")[0]
        Rails.logger.info "PHOTO PATH #{photo_path} \n"
              
        result = @client.create_post @photo.user.me2day_id, 'post[body]' => "#{truncate(@photo.title, :length => 120)} #{shortened_url(@photo)}", 'attachment' => File.new(photo_path)

        Rails.logger.info "POST RESULT #{result.inspect}}"
=end              
      end  
    end 

  end  

end  
