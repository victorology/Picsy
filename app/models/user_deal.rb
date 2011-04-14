class UserDeal < ActiveRecord::Base
  belongs_to :category,:foreign_key => 'type_id'
  belongs_to :item_type,:foreign_key => 'type_id'
  belongs_to :user
end
