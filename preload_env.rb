require './lib/app_env'
require 'slim'
require 'faker'
require 'tilt/coffee'
require 'yaml'
if AppEnv.development?
  require 'dotenv'
  Dotenv.load
end
