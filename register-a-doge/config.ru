require 'sinatra'

require_relative 'register-a-doge'
set :bind, '0.0.0.0'
run Sinatra::Application.run!
