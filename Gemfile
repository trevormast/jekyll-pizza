source 'https://rubygems.org'
ruby '2.2.3'

gem 'sinatra'
gem 'slim'
gem 'sinatra_auth_github'
gem 'faker'
gem 'coffee-script'
gem 'rack-ssl-enforcer'
gem 'puma'
gem 'dweet', github: 'vannell/ruby-dweetio'
gem 'sass'
gem 'sidekiq'
gem 'sidekiq_status', git: 'https://github.com/cryo28/sidekiq_status.git'
gem 'redis'

group :development do
  gem 'jekyll', '~> 3.0.0'
  gem 'rerun'
  gem 'rubocop', require: false
  gem 'dotenv'
  gem 'rake'
  gem 'httplog'
end

group :development, :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'pry'
end

group :test do
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'json'
end
