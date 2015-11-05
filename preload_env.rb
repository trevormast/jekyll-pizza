require './lib/app_env'
if AppEnv.development?
  require 'dotenv'
  Dotenv.load
end
