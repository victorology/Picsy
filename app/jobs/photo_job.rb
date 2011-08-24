class PhotoJob < Struct.new(:photo_id, :host_with_port)  
  
  def perform  
    @photo = Photo.find(photo_id)
    @photo.host_with_port = host_with_port
    
    #upload to fb default album 
    @photo.fb_photo
    
    #upload to fb custom album
    @photo.fb_photo_to_album
 
    #upload to fb wall
    @photo.fb_wall

    #upload to tumblr
    @photo.tumblr_photo
    
    #upload to twitter
    @photo.twitter
 
    #upload to me2day
    @photo.me2day
  end  

end  