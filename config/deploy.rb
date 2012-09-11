
set :user, 'ubuntu'
set :domain, 'lifeofadev.marcosero.com'
set :application, 'lifeofadev'

# the link of repository take advantage of file .ssh/config
# to use the path of the private key
# ms is just a shortcut for the host
#   Host ms
#   HostName marcosero.com
#   User ubuntu
#   IdentityFile ~/.ssh/marcosero.pem 
set :repository, "ms:git/#{application}.git"
set :deploy_to, "/home/#{user}/public_html/#{application}" 

ssh_options[:keys] = %w(~/.ssh/marcosero.pem)

# distribute your applications across servers (the instructions below put them
# all on the same server, defined above as 'domain', adjust as necessary)
role :app, domain
role :web, domain
role :db, domain, :primary => true

# you might need to set this if you aren't seeing password prompts
# default_run_options[:pty] = true

# As Capistrano executes in a non-interactive mode and therefore doesn't cause
# any of your shell profile scripts to be run, the following might be needed
# if (for example) you have locally installed gems or applications.  Note:
# this needs to contain the full values for the variables set, not simply
# the deltas.
# default_environment['PATH']='<your paths>:/usr/local/bin:/usr/bin:/bin'
# default_environment['GEM_PATH']='<your paths>:/usr/lib/ruby/gems/1.8'

# miscellaneous options
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false

namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=production"
  end
end

after "deploy:update_code", :bundle_install
desc "install the necessary prerequisites"
task :bundle_install, :roles => :app do
  run "cd #{release_path} && bundle install"
end

# copy db config
after "deploy:update_code", :copy_db_config
desc "copy db config file"
task :copy_db_config do
  run "ln -s ~/public_html/lifeofadev/database.yml #{release_path}/config/database.yml"
end
