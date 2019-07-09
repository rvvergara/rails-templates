def add_gems
  gemfile = Dir.glob("Gemfile")[0]

  insert_into_file gemfile,
  "\ngem 'devise'\ngem 'pundit'\ngem 'jwt'\ngem 'jbuilder', '~> 2.5'\ngem 'rack-cors'",
  after: "gem 'bootsnap', '>= 1.1.0', require: false"

  insert_into_file gemfile,
  "
  gem 'hirb'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'faker'
  gem 'factory_bot_rails'",
  after: "group :development, :test do"

  insert_into_file gemfile,
  "
  gem 'spring-commands-rspec'",
  after: "group :development do"
end

def remove_comments_from_gemfile
  gemfile = Dir.glob("Gemfile")[0]
  git_source = 'git_source(:github) { |repo| "https://github.com/#{repo}.git" }'
  gsub_file gemfile, /((#.+)?\s*(#.+))*/, ""
  gsub_file gemfile, /(git_source.*)/, "#{git_source}"
end

def add_configuration_to_application
  application_rb = Dir.glob("config/application.rb")[0]
  gsub_file application_rb, /((#.*)?\s*(#.*))*/,""
  insert_into_file application_rb,
  "    
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid

      g.test_framework :rspec,
          view_specs: false,
          helper_specs: false,
          controller_specs: false,
          routing_specs: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost:8080'
    
        resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
  ", 
after: "config.api_only = true"
end

def configure_database_yml
  dbyml = Dir.glob("config/database.yml")[0]
  gsub_file dbyml, /((#.*)?\s*(#.*))*/, ""
  insert_into_file dbyml, 
  "
  host: localhost
  timeout: 5000
  after: "encoding: unicode"
end

def setup_db
  run "rails db:drop"
  run "rails db:create"
end

def generate_enable_pgycrypto_migration
  generate "migration EnablePgCryptoExtension"
  migration = Dir.glob("db/migrate/*")[0]
  insert_into_file migration,
  "
    enable_extension 'pgcrypto'",
  after: "def change"
  run "rails db:migrate"
end

def make_uuid
  add_configuration_to_application
  configure_database_yml
  setup_db
  generate_enable_pgycrypto_migration
end

def use_devise
  generate "devise:install"
end

def use_rspec
  generate "rspec:install"
  
  rails_helper = Dir.glob("spec/rails_helper.rb")[0]

  insert_into_file rails_helper,
  "
  config.include FactoryBot::Syntax::Methods",
  after: "RSpec.configure do |config|"

  run "bundle exec spring binstub rspec"
end

def use_pundit
 generate "pundit:install"
 
 application_controller = Dir.glob("app/controllers/application_controller.rb")[0]
 
 insert_into_file application_controller,
 "
 include Pundit",
 after: "ActionController::API"
end

def create_jwt_service_file
  run "mkdir 'app/services'"
  run "touch app/services/json_web_token.rb"

  jwt_service = Dir.glob("app/services/json_web_token.rb")[0]
  append_to_file jwt_service, 
  "
  class JsonWebToken
    SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
  
    def self.encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY)
    end
  
    def self.decode(token)
      decoded = JWT.decode(token, SECRET_KEY)[0]
      HashWithIndifferentAccess.new(decoded)
    end
  end
  "
end


remove_comments_from_gemfile

add_gems

after_bundle do
  make_uuid
  use_devise
  use_rspec
  create_jwt_service_file
  use_pundit
  run "git add . && git commit -m 'Project set up and initial commit' && git checkout -b development"
end