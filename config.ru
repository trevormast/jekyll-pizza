$stdout.sync = true

ENV['RACK_ENV'] ||= 'development'
require 'rubygems'
require 'bundler/setup'
require './preload_env'
require './app'

# use Rack::Static, :urls => ["/css", "/img", "/js"], :root => "public"

run BlogPoole::App
