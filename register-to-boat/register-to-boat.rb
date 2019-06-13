require 'sinatra'
require_relative 'db'
#require 'rest-client'
require 'net/http'
require 'uri'
require 'openssl'

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
  erb :register, locals: {
    registration: Registration.new,
  }
end

post '/register' do

  if params[:first_name] == "Troll" && params[:last_name] == "Face"

    uri = URI.parse("https://splunk:8089/services/messages")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("admin", "correcthorsebatterystaple")
    request.body = "name=userAlert&value='Troll Face' registered"
    req_options = {
      use_ssl: uri.scheme == "https",
      verify_mode: OpenSSL::SSL::VERIFY_NONE,
    }
    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  registration = Registration.new
  registration.first_name = params[:first_name]
  registration.last_name = params[:last_name]

  unless registration.valid?
    return erb :register, locals: {
      registration: registration,
    }
  end

  registration.save!

  erb :success, locals: { registration: registration }
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
