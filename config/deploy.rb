require "bundler/capistrano"
require 'capistrano/ext/multistage'

set :stages, "production"
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
 
  task :bundle_new_release, :roles => :app do
    # make sure use ruby 1.9.2
    run "rvm use 1.9.2"
    #bundler.create_symlink
    run "cd #{current_path} && bundle install --local"
  end
end

 
after 'deploy:update_code', 'bundler:bundle_new_release' 

