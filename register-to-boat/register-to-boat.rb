require 'sinatra'
require_relative 'db'

unless $0.match?(/rspec/)
  setup_db_connection
  create_database
end

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
  locals = {registrations: [
    { name: 'Today',      value: Registration.registrations_today.count },
    { name: 'This week',  value: Registration.registrations_this_week.count },
    { name: 'This month', value: Registration.registrations_this_month.count },
    { name: 'This year',  value: Registration.registrations_this_year.count },
    { name: 'All time',   value: Registration.count },
  ]}

  erb :stats, locals: locals
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
