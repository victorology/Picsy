class Invite < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  after_save :guid_update

  protected
  def guid_update
    the_id = "#{UUID.new.generate[0..2]}#{self.id}"
    iv = Invite.where(:guid => the_id )
    
    if iv.size > 0
      guid_update
    else
      Invite.update_all "guid='#{the_id}'","id=#{self.id}"
    end    
  end  
  
end
