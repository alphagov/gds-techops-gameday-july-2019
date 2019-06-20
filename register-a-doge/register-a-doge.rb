require 'sinatra'
require_relative 'db'
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

def splunk_message(logger, message)
  uri = URI.parse("#{ENV['SPLUNK_URI']}/services/collector/event")
  begin
    request = Net::HTTP::Post.new(uri)
    request.basic_auth('x', ENV['SPLUNK_KEY'])
    request.body = { event: message, sourcetype: 'userAlert' }.to_json

    response = Net::HTTP.start(
      uri.hostname, uri.port,
      use_ssl: uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE
    ) { |http| http.request(request) }

    logger.info response.body

    if response.code.to_s.match?(/^2+/)
      logger.info 'Success posting to splunk'
    else
      logger.error "Failure posting to splunk: #{response.body}"
    end
  rescue StandardError => e
    logger.error e
  end
end

post '/register' do
  splunk_message(
    logger,
    "POST /register: [fname=#{params[:first_name]} ; lname=#{params[:last_name]}]"
  )

  registration = Registration.new
  registration.first_name = params[:first_name]
  registration.last_name = params[:last_name]

  unless registration.valid?
    return erb :register, locals: { registration: registration }
  end

  registration.save!

  erb :success, locals: { registration: registration }
end

get '/stats' do
  locals = { registrations: [
    { name: 'Today',      value: Registration.registrations_today.count },
    { name: 'This week',  value: Registration.registrations_this_week.count },
    { name: 'This month', value: Registration.registrations_this_month.count },
    { name: 'This year',  value: Registration.registrations_this_year.count },
    { name: 'All time',   value: Registration.count }
  ] }

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
