require 'sinatra'

# We want to call our templates template.html.erb
Tilt.register Tilt::ERBTemplate, 'html.erb'

get '/' do
  erb :index
end

get '/register' do
  erb :register
end

get '/form' do
  erb :form
end

post '/form' do
  raise 'Not implemented'
end

get '/stats' do
  erb :stats
end

get '/500' do
  raise '500 page'
end

get '/_health' do
  '200 - this healthcheck could be better, no?'
end

error do
  erb :error
end

not_found do
  erb :'404'
end
