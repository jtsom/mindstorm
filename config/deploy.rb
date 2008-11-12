set :application, "Mindstorm"
set :repository,  "git://github.com/jtsom/mindstorm.git"
set :scm, :git

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "spssql.shrewsbury.k12.ma.us"
role :web, "spssql.shrewsbury.k12.ma.us"
role :db,  "spssql.shrewsbury.k12.ma.us", :primary => true