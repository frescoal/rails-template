run 'pgrep spring | xargs kill -9'

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

# Assets
########################################
run 'rm -rf app/assets/stylesheets'
run 'rm -rf app/assets/javascripts'
run 'rm -rf vendor'
run 'curl -L https://github.com/frescoal/rails-template/archive/master.zip > assets.zip'
run 'unzip assets.zip/assets -d app/assets && rm assets.zip'

# Dev environment
########################################
gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

# Layout
########################################
run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>TODO</title>
    <%= csrf_meta_tags %>
    <%= action_cable_meta_tag %>
    <%= stylesheet_link_tag 'application', media: 'all' %>
    <%#= stylesheet_pack_tag 'application', media: 'all' %> <!-- Uncomment if you import CSS in app/javascript/packs/application.js -->
  </head>
  <body>
    <%= render 'shared/flashes' %>
    <%= yield %>
    <%= javascript_include_tag 'application' %>
    <%= javascript_pack_tag 'application' %>
  </body>
</html>
HTML

file 'app/views/shared/_flashes.html.erb', <<-HTML
<% if notice %>
  <div class="alert alert-info alert-dismissible fade show m-1" role="alert">
    <%= notice %>
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>
<% end %>
<% if alert %>
  <div class="alert alert-warning alert-dismissible fade show m-1" role="alert">
    <%= alert %>
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>
<% end %>
HTML

run 'curl -L https://wavemind.ch/wp-content/uploads/2019/04/wav-logo.png > app/assets/images/logo.png'

insert_into_file "config/application.rb", after: "config.load_defaults 5.2" do
  "\n    config.exceptions_app = self.routes\n    config.time_zone = 'Bern'\n    I18n.config.available_locales = :fr"
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
  # Generators: db + simple form + pages controller
  ########################################
  generate('simple_form:install', '--bootstrap')
  generate(:controller, 'dashboard', 'index', '--skip-routes', '--no-test-framework')

  # Routes
  ########################################
  route "root to: 'dashboard#index'"
  route "get '/404', to: 'errors#not_found'"
  route "get '/422', to: 'errors#unacceptable'"
  route "get '/500', to: 'errors#internal_error'"

  # Git ignore
  ########################################
  append_file '.gitignore', <<-TXT

# Ignore .env file containing credentials.
.env*

# Ignore Mac and Linux file system files
*.swp
.DS_Store
  TXT

  # Devise install + user
  ########################################
  generate('devise:install')
  generate('devise', 'User')

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<-RUBY
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
end
  RUBY

  # Error Managment
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
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/404.html.erb > app/views/errors/not_found.html.erb'
  run 'curl -L https://raw.githubusercontent.com/frescoal/rails-template/master/500.html.erb > app/views/errors/internal_server_error.html.erb'

  # Devise views
  ########################################
  generate('devise:views')

  # Pages Controller
  ########################################
  run 'rm app/controllers/dashboard_controller.rb'
  file 'app/controllers/dashboard_controller.rb', <<-RUBY
class DashboardController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
  end
end
  RUBY

  # Environments
  ########################################
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: 'development'
  environment 'config.action_mailer.default_url_options = { host: "https://TODO_PUT_YOUR_DOMAIN_HERE" }', env: 'production'

  # Webpacker / Yarn
  ########################################
  run 'rm app/javascript/packs/application.js'
  run 'yarn add popper.js jquery bootstrap'
  file 'app/javascript/packs/application.js', <<-JS
import "bootstrap";
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
  git commit: "-m 'Initial commit with devise only'"
end
