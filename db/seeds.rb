# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

ItemType.destroy_all
Category.destroy_all
Item.destroy_all
User.destroy_all
Setting.destroy_all

### admin data for temporary, once change pwd feature is built, this data must be removed
admin = User.create(:email => "admin@pumpl.com",:password => "super4dmin", :password_confirmation => "super4dmin", :nickname => "admin")
admin.confirmed_at = Time.now
admin.is_admin = true
admin.save

### user data, it's used for test purpose only
user = User.create(:email => "aditya.jamop@gmail.com",:password => "work1234", :password_confirmation => "work1234", :nickname => "aditya")
user.confirmed_at = Time.now
user.is_admin = false
user.save

@item_types = []
["맛집.카페","술집.와인","뷰티.생활","레저.취미","공연.전시","여행","기타"].each do |itype|
  @item_types << ItemType.create(:name => itype)
end  

@categories = []
["서울","강남","강북","경기도","	일산","분당","경기도 기타","	경상도","부산","대구","경상도 기타","인천","전라도","충청도","강원도","기타"].each_with_index do |cat,idx|
  if idx == 1 or idx ==2
    parent_id = 19
  elsif idx >= 4 and idx <= 6
    parent_id = 22
  elsif idx >= 7 and idx <= 10
    parent_id = 26  
  else
    parent_id = nil
  end      
  @categories << Category.create(:name => cat, :parent_id => parent_id)
end
=begin
example_food_item = Item.create(
  :title =>" 청담동 << 소문난 이탈리아 파스타 “루고”! 소문난 이탈리아 파스타 “루고”!",
  :url => "http://www.nicepasta.com",
  :picture_url => "http://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Pasta_with_pesto.jpg/250px-Pasta_with_pesto.jpg",
  :deal_price => 39000,
  :original_price => 78000,
  :begin_date => 1.month.ago,
  :finish_date => Time.now.advance(:days => 1),
  :sales_cnt => 200,
  :max_sales_cnt => 250,
  :categories => [@categories[0],@categories[6]],
  :item_type_id => @item_types[0].id
)


food_item1 = Item.create(
  :title =>"음식 1 << 아주 맛있는 음식, 그것은 건강에 좋은 아주 맛있는 음식, 그것은 건강에 좋은",
  :url => "http://www.cuisine.com",
  :image => File.open(RAILS_ROOT+"/public/images/items/food1.jpg"),
  :deal_price => 40000,
  :original_price => 50000,
  :begin_date => 1.month.ago,
  :finish_date => Time.now.advance(:days => 2),
  :sales_cnt => 100,
  :max_sales_cnt => 250,
  :categories => [@categories[4]],
  :item_type_id => @item_types[0].id
) 

food_item2 = Item.create(
  :title =>"음식 2 << 아주 맛있는 음식, 그것은 건강에 좋은 아주 맛있는 음식, 그것은 건강에 좋은",
  :url => "http://www.food.com",
  :picture_url => "http://img19.imageshack.us/img19/9554/koreanfood.jpg",
  :deal_price => 30000,
  :original_price => 35000,
  :begin_date => 25.days.ago,
  :finish_date => Time.now.advance(:days => 20),
  :sales_cnt => 423,
  :max_sales_cnt => 1000,
  :categories => [@categories[0]],
  :item_type_id => @item_types[0].id
)

food_item3 = Item.create(
  :title =>"음식 3 << 아주 맛있는 음식, 그것은 건강에 좋은 아주 맛있는 음식, 그것은 건강에 좋은",
  :url => "http://www.eat.com",
  :image => File.open(RAILS_ROOT+"/public/images/items/food3.jpg"),
  :deal_price => 15000,
  :original_price => 45000,
  :begin_date => 24.days.ago,
  :finish_date => Time.now.advance(:days => 16),
  :sales_cnt => 1003,
  :max_sales_cnt => 1500,
  :categories => [@categories[0]],
  :item_type_id => @item_types[0].id
) 

food_item4 = Item.create(
  :title =>"동치미국수 << 아주 맛있는 음식, 그것은 건강에 좋은 아주 맛있는 음식, 그것은 건강에 좋은",
  :url => "http://www.yummy.com",
  :image => File.open(RAILS_ROOT+"/public/images/items/yummy.jpg"),
  :deal_price => 9600,
  :original_price => 22500,
  :begin_date => 24.days.ago,
  :finish_date => Time.now.advance(:days => 18),
  :sales_cnt => 10,
  :max_sales_cnt => 500,
  :categories => [@categories[1]],
  :item_type_id => @item_types[0].id
)

stuff_item1 = Item.create(
  :title => "Nintendo WII",
  :url => "http://www.gamecenter.com/",
  :image => File.open(RAILS_ROOT+"/public/images/items/wii.jpg"),
  :deal_price => 300000,
  :original_price => 325000.50,
  :begin_date => 23.days.ago,
  :finish_date => Time.now.advance(:days => 19),
  :sales_cnt => 25,
  :max_sales_cnt => 300,
  :categories => [@categories[1]],
  :item_type_id => @item_types[1].id
)

stuff_item2 = Item.create(
  :title => "Macbook Pro",
  :url => "http://www.fakemac.com",
  :image => File.open(RAILS_ROOT+"/public/images/items/mbp.jpg"),
  :deal_price => 999000,
  :original_price => 1350000,
  :begin_date => 23.days.ago,
  :finish_date  => Time.now.advance(:days => 17),
  :categories => [@categories[7]],
  :item_type_id => @item_types[1].id,
  :sales_cnt => 250,
  :max_sales_cnt => 250
)

stuff_item3 = Item.create(
  :title => "Panasonic Plasma 3D TV",
  :url => "http://www.3dtv.com",
  :picture_url => "http://img254.imageshack.us/img254/7250/3dtv.png",
  :deal_price => 2499999,
  :original_price => 2850000,
  :begin_date => 20.days.ago,
  :finish_date  => Time.now.advance(:days => 20),
  :categories => [@categories[0]],
  :item_type_id => @item_types[1].id,
  :sales_cnt => 100,
  :max_sales_cnt => 90
)

expired_item = Item.create (
  :title => "Suzuki Kizashi",
  :url => "http://www.kizashi.com/",
  :image => File.open(RAILS_ROOT+"/public/images/items/kizashi.jpg"),
  :deal_price => 129000000,
  :original_price => 179000000,
  :begin_date => Time.now.advance(:days => -7),
  :finish_date => Time.now.advance(:days => -9),
  :categories => [@categories[4],@categories[7],@categories[1]],
  :item_type_id => @item_types[1].id
)

expired_item2 = Item.create(
  :title => "Ferarri Fiorano",
  :url => "http://www.ferarri.com",
  :picture_url => "http://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Ferrari599_A6_1.JPG/250px-Ferrari599_A6_1.JPG",
  :deal_price => 150000000,
  :original_price => 215000000,
  :begin_date => Time.now.advance(:days => -9),
  :finish_date => Time.now.advance(:days => -10),
  :categories => [@categories[0],@categories[6]],
  :item_type_id => @item_types[1].id
)
=end


  

  