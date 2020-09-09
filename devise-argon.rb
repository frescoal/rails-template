# run 'pgrep spring | xargs kill -9'

# GEMFILE
########################################
run 'rm Gemfile'
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '#{RUBY_VERSION}'

#{"gem 'bootsnap', require: false" if Rails.version >= "5.2"}
gem 'devise'
gem 'jbuilder', '~> 2.0'
gem 'pg'
gem 'tzinfo-data'
gem 'puma'
gem 'rails', '#{Rails.version}'
gem 'redis'

gem 'autoprefixer-rails'
gem 'font-awesome-sass', '~> 5.6.1'
gem 'sassc-rails'
gem 'simple_form'
gem 'cocoon'
gem 'uglifier'
gem 'webpacker'

# Template
gem 'bootstrap', '~> 4.3.1'
gem 'js_cookie_rails'
gem 'jquery-rails'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'bullet'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'dotenv-rails'
end
RUBY

# Procfile
########################################
file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

# Dev environment
########################################
gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

run 'curl -L https://wavemind.ch/wp-content/uploads/2019/04/wav-logo.png > app/assets/images/logo.png'

# Application.rb
insert_into_file "config/application.rb", after: "config.load_defaults 5.2" do
  "\n    config.exceptions_app = self.routes\n    config.time_zone = 'Bern'\n    I18n.config.available_locales = :fr\n    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')\n    config.i18n.default_locale = :fr"
end

# Generators
########################################
generators = <<-RUBY
config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework  :test_unit, fixture: false
    end
RUBY

environment generators

########################################
# AFTER BUNDLE
########################################
after_bundle do

  # Generators: simple form
  ########################################
  generate(:controller, 'dashboard', 'index', '--skip-routes', '--no-test-framework')
  generate('simple_form:install', '--bootstrap')

  # Devise install + user
  ########################################
  generate('devise:install')
  generate('devise', 'User')

  gsub_file('config/initializers/devise.rb', /# config\.mailer = 'Devise::Mailer'/, "config.mailer = 'CustomDeviseMailer'")

  # Assets
  ########################################
  run 'rm -rf app/assets/stylesheets'
  run 'rm -rf app/assets/javascripts'
  run 'rm -rf app/views/*'
  run 'rm -rf vendor'
  run 'mkdir app/inputs'
  run 'curl -L https://github.com/frescoal/rails-template/archive/master.zip > wavemind.zip'
  run 'unzip wavemind.zip -d wavemind && rm wavemind.zip'
  run 'mv -v -f wavemind/rails-template-master/assets/* app/assets/'
  run 'mv -v -f wavemind/rails-template-master/views/* app/views/'
  run 'mv -v -f wavemind/rails-template-master/locales/* config/locales/'
  run 'mv -v -f wavemind/rails-template-master/inputs/* app/inputs/'
  run 'rm -rf wavemind/'
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/simple_form_bootstrap.rb > config/initializers/simple_form_bootstrap.rb'

  # Routes
  ########################################
  run 'rm config/routes.rb'
  file 'config/routes.rb', <<-RUBY
Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root 'dashboard#index'
  end
  unauthenticated :user do
    devise_scope :user do
      get '/' => 'devise/sessions#new'
    end
  end
end
  RUBY

  # Git ignore
  ########################################
  append_file '.gitignore', <<-TXT

# Ignore .env file containing credentials.
.env*
.idea/*
.vscode/*

# Ignore Mac and Linux file system files
*.swp
.DS_Store
  TXT

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<-RUBY
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  layout :layout_by_resource

  # Define layout if user is connected
  def layout_by_resource
    if user_signed_in?
      'application'
    else
      'login'
    end
  end
end

  RUBY

  # Error Management
  ########################################
  file 'app/controllers/errors_controller.rb', <<-RUBY
class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!

  def not_found
    render status: 404
  end

  def internal_error
    render status: 500
  end
end
  RUBY

  run 'mkdir app/views/errors'
  run 'mkdir app/javascript/application'
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/404.html.erb > app/views/errors/not_found.html.erb'
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/500.html.erb > app/views/errors/internal_server_error.html.erb'
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/sweet-alert-confirm.js > app/javascript/application/sweet-alert-confirm.js'
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/custom_devise_mailer.rb > app/mailers/custom_devise_mailer.rb'
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/application_helper.rb > app/helpers/application_helper.rb'

  # Environments
  ########################################
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: 'development'
  environment 'config.action_mailer.default_url_options = { host: "https://TODO_PUT_YOUR_DOMAIN_HERE" }', env: 'production'

  # Webpacker / Yarn
  ########################################
  run 'rm app/javascript/packs/application.js'
  run 'yarn add popper.js jquery bootstrap sweetalert2 rails-ujs'
  file 'app/javascript/packs/application.js', <<-JS
import "bootstrap";
import 'application/sweet-alert-confirm';
  JS

  inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
    <<-JS
const webpack = require('webpack')
// Preventing Babel from transpiling NodeModules packages
environment.loaders.delete('nodeModules');

// Bootstrap 4 has a dependency over jQuery & Popper.js:
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default']
  })
)

    JS
  end

  # Dotenv
  ########################################
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/.env > .env'

  # Database Configuration
  ########################################
  insert_into_file "config/database.yml", after: "development:\n  <<: *default\n" do
    "  username: <%= ENV['DEV_DB_USERNAME'] %>\n  password: <%= ENV['DEV_DB_PASSWORD'] %>\n"
  end
  gsub_file('config/database.yml', /database: .*/, 'database: <%= ENV[\'DEV_DB_NAME\'] %>')
  gsub_file('config/database.yml', /test:\n  <<: \*default\n  database: <%= ENV\['DEV_DB_NAME'\] %>/, 'test:')

  insert_into_file "config/database.yml", after: "test:" do
    "\n  <<: *default\n  database: <%= ENV['TEST_DB_NAME'] %>\n  password: <%= ENV['TEST_DB_PASSWORD'] %>\n  username: <%= ENV['TEST_DB_USERNAME'] %>\n"
  end

  # Development config
  ########################################
  insert_into_file "config/environments/development.rb", after: "config.file_watcher = ActiveSupport::EventedFileUpdateChecker\n" do
    config = []
    config << ""
    config << "  BetterErrors::Middleware.allow_ip! '0.0.0.0/0'"
    config << ""
    config << "  # Make .env file work in development"
    config << "  Bundler.require(*Rails.groups)"
    config << "  Dotenv::Railtie.load"
    config << ""
    config << "  # Config Bullet"
    config << "  config.after_initialize do"
    config << "    Bullet.enable = true"
    config << "    Bullet.rails_logger = true"
    config << "    # Whitelist"
    config << "  end"
    config << ""
    config << "  # Mailcatcher"
    config << "  config.action_mailer.perform_deliveries = true"
    config << "  config.action_mailer.delivery_method = :smtp"
    config << "  config.action_mailer.smtp_settings = {address: 'localhost', port: 1025}"
    config << "  config.action_mailer.default_url_options = {host: 'localhost:3000'}"
    config << "  config.action_mailer.raise_delivery_errors = true\n"
    config.join("\n")
  end


  # Rubocop
  ########################################
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/.rubocop.yml > .rubocop.yml'
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/.rubocop_airbnb.yml > .rubocop_airbnb.yml'

  # Editorconfig
  ########################################
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/.editorconfig > .editorconfig'

  # Git
  ########################################
  git :init
  git add: '.'
  git commit: "-m 'Initial commit with devise with argon template'"
end
