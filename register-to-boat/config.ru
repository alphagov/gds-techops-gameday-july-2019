require 'sinatra'

require_relative 'register-to-boat'
set :bind, '0.0.0.0'
run Sinatra::Application.run!
