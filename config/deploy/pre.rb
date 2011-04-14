set :scm, :git
set :user, :capdeploy
set :deploy_to, "/passenger/nginx/pumpl"
set :port, "13481"
set :rails_env, "pre"
set :branch, "pre"

role :web, "184.106.216.249"                          
role :app, "184.106.216.249"                         
role :db,  "184.106.216.249", :primary => true