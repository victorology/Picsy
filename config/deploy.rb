require "bundler/capistrano"
require 'capistrano/ext/multistage'

set :stages, ["production"]
set :default_stage, "production"
set :application, "picsy"
set :repository,  "git@github.com:victorology/Picsy.git"

default_run_options[:pty] = true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    sudo "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
 
namespace :bundler do
  desc "Symlink bundled gems on each release"
  task :symlink_bundled_gems, :roles => :app do
    run "rvm use 1.9.2"
    run "mkdir -p #{shared_path}/bundled_gems"
    run "ln -nfs #{shared_path}/bundled_gems #{release_path}/vendor/bundle"
  end

  desc "Install for production"
  task :install, :roles => :app do
    run "cd #{release_path} && bundle install"
  end

end

namespace :delayed_job do 
    desc "Restart the delayed_job process"
    task :restart, :roles => :app do
        run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart"
    end
end

after 'deploy:update_code', 'bundler:symlink_bundled_gems'
after 'deploy:update_code', 'bundler:install'
after "deploy:update_code", "delayed_job:restart"

 

