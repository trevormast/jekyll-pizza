$stdout.sync = true

ENV['RACK_ENV'] ||= 'development'
require 'rubygems'
require 'bundler/setup'
require './preload_env'
require './app'
require 'sass/plugin/rack'
use Sass::Plugin::Rack

# use for static file hosting
# use Rack::Static, :urls => ["/css", "/img", "/js"], :root => "public"

run JekyllPizza::App
