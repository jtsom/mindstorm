set :application, "mindstorm"
set :repository,  "git://github.com/jtsom/mindstorm.git"
set :scm, :git

set :deploy_to, "/home/jtsombakos/public_html/#{application}"

role :app, "spssql.shrewsbury.k12.ma.us"
role :web, "spssql.shrewsbury.k12.ma.us"
role :db,  "spssql.shrewsbury.k12.ma.us", :primary => true

set :user, "jtsombakos"
set :admin_runner, "jtsombakos"
#set :use_sudo, false

default_run_options[:pty] = true

set :branch, "master"

namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  # desc "Symlink shared configs and folders on each release."
  # task :symlink_shared do
  #   run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  #   run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
  # end

  desc "Start Application - not needed with Passenger"
  task :start, :roles => :app do
    # nothing to do
  end
end

#after 'deploy:update_code', 'deploy:symlink_shared'