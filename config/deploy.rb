require 'rvm/capistrano'
require 'bundler/capistrano'


set :application, "sample"
set :repository,  "git://github.com/unnitallman/rails3-bootstrap-devise-cancan.git"

set :scm, :git

role :web, "192.210.137.100"
role :app, "192.210.137.100"
role :db,  "192.210.137.100"

ssh_options[:forward_agent] = true
set :deploy_via, :remote_cache
set :use_sudo, false
set :user, "unni"
set :deploy_to, "/home/unni/sample"
set :rails_env, "production"
set :rvm_type, :user

set :keep_releases, 3
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  desc "Symlink shared/* files"
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

namespace :deploy do
  desc "Restart passenger"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :database do
  task :migrate do
    run "cd #{current_path} && bundle exec rake db:migrate RAILS_ENV=#{rails_env}"
  end
end

after "deploy:update_code", "deploy:symlink_shared"
after "deploy:update_code", "database:migrate"
