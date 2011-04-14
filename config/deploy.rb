require "bundler/capistrano"
require 'capistrano/ext/multistage'

set :stages, %w(pre production)
set :default_stage, "pre"
set :application, "pumpl deal aggregator"
set :repository,  "git@github.com:victorology/PUMPL.git"

default_run_options[:pty] = true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    sudo "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
 
namespace :bundler do
  #task :create_symlink, :roles => :app do
  #  shared_dir = File.join(shared_path, 'bundle')
  #  release_dir = File.join(current_release, '.bundle')
  #  run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  #end
 
  task :bundle_new_release, :roles => :app do
    #bundler.create_symlink
    run "cd #{current_path} && bundle install --local"
  end
end

namespace :git do
  task :back_to_pre do
    system("git checkout pre")  
  end  
end  
 
after 'deploy:update_code', 'bundler:bundle_new_release' 
after 'deploy:restart','git:back_to_pre'

