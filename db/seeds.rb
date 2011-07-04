# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

User.destroy_all
Setting.destroy_all

### admin data for temporary, once change pwd feature is built, this data must be removed
admin = User.create(:email => "admin@pumpl.com",:password => "super4dmin", :password_confirmation => "super4dmin", :nickname => "admin", :phone_number => "999999")
admin.confirmed_at = Time.now
admin.is_admin = true
admin.save

### user data, it's used for test purpose only
user = User.create(:email => "aditya.jamop@gmail.com",:password => "work1234", :password_confirmation => "work1234", :nickname => "aditya", :phone_number => "88888")
user.confirmed_at = Time.now
user.is_admin = false
user.save

### another user data, it's used for test purpose only
user = User.create(:email => "v@victor.is",:password => "test1234", :password_confirmation => "test1234", :nickname => "victor", :phone_number => "77777")
user.confirmed_at = Time.now
user.is_admin = false
user.save

### user data with space, it's used for test purpose only
user = User.create(:email => "heo@gmail.com",:password => "work1234", :password_confirmation => "work1234", :nickname => "heo si jin", :phone_number => "88888")
user.confirmed_at = Time.now
user.is_admin = false
user.save

  