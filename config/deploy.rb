require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/rvm'    # for rvm support. (https://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'baibonjwa-blog'
set :domain, 'baibonjwa.com'
set :deploy_to, '/var/www/baibonjwa-blog'
set :repository, 'git@github.com:BAI-Bonjwa/baibonjwa-blog.git'
set :branch, 'master'

# Optional settings:
set :user, 'happybai'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

set :nvm_path, '/home/happybai/.nvm/scripts/nvm'

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_dirs, fetch(:shared_dirs, []).push()
set :shared_files, fetch(:shared_files, []).push(
  '.env.production',
)

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
  command 'echo "-----> Loading nvm"'
  command %{
    source ~/.nvm/nvm.sh
  }
  command 'echo "-----> Now using nvm v.`nvm --version`"'
  command 'export PATH="$HOME/.yarn/bin:$PATH"'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0 --skip-existing}
end

desc "Deploys the current version to the server."
task :deploy do
  # run(:local) do
  #   command "scp .env.production #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/.env.production"
  # end
  # uncomment this line to make sure you pushed your local branch to the remote origin
  invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    command "nvm use node 10.15.3"
    command "yarn install"
    command "yarn build"

    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts

  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
