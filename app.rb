
require 'sinatra'

get '/' do
  slim :index, layout: :default
end
