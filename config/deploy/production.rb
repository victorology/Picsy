system("git checkout pre")
system("git pull origin pre")
system("git checkout production")
system("git merge pre")
system("git push origin production")

set :scm, :git
set :user, :victor
set :deploy_to, "/passenger/nginx/pumpl"
set :port, "13481"
set :rails_env, "production"
set :branch, "production"

role :web, "175.126.73.169"                          
role :app, "175.126.73.169"  
role :db,  "175.126.73.169", :primary => true

namespace :db_production do
  task :copy do
    run "cp /home/victor/pumpl/database.yml #{current_path}/config/"
  end
end               

after 'deploy:symlink','db_production:copy'            
