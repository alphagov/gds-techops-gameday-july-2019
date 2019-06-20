#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'openssl'
require 'securerandom'
require 'uri'

SPLUNK_USER     = ENV.fetch('SPLUNK_USER', 'admin')
SPLUNK_PASS     = ENV.fetch('SPLUNK_PASS')
SPLUNK_URL      = ENV.fetch('SPLUNK_URL')
HEC_URL         = ENV.fetch('HEC_URL', SPLUNK_URL.sub('splunk-admin', 'hec'))
IDENTIFIER      = ENV.fetch('IDENTIFIER')

def success(*args)
  puts ['✅', *args].join(' ')
end

def failure(*args)
  abort ['❌', *args].join(' ')
end

def info(*args)
  puts ['🆗', *args].join(' ')
end

def splunk_http(method, path, params)
  uri = URI("#{SPLUNK_URL}/#{path}?output_mode=json")

  if method == 'get'
    uri.query = URI.encode_www_form(params.update(output_mode: 'json'))
  end

  request = Net::HTTP.const_get(method.capitalize).new(uri)
  request.basic_auth(SPLUNK_USER, SPLUNK_PASS)
  request.body = URI.encode_www_form(params) unless method == 'get'

  http             = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl     = uri.scheme == 'https'
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.host.match?(/localhost/)

  http.start { |http| http.request(request) }
end

info "Creating index #{IDENTIFIER}"
i_resp = splunk_http(
  'post', 'services/data/indexes', { name: IDENTIFIER , datatype: 'event' }
)
failure "Error creating index: #{i_resp.body}" unless i_resp.code.match?(/^2/)
success "Created index #{IDENTIFIER}"

info "Creating key #{IDENTIFIER} for index #{IDENTIFIER}"
k_resp = splunk_http(
  'post', 'services/data/inputs/http',
  { name: IDENTIFIER , index: IDENTIFIER, indexes: IDENTIFIER }
)
failure "Error creating key: #{k_resp.body}" unless k_resp.code.match?(/^2/)
key = JSON.parse(k_resp.body).dig('entry').first.dig('content', 'token')
success "Created key #{IDENTIFIER} => #{key}"

info 'Sending a test message'
hec_uri = URI("#{HEC_URL}/services/collector/event")
request = Net::HTTP::Post.new(hec_uri)
request.basic_auth('x', key)
request.body = {
  event: "Initial message #{IDENTIFIER}", sourcetype: 'useralert'
}.to_json
hec_resp = Net::HTTP.start(
  hec_uri.hostname, hec_uri.port, use_ssl: true
) { |http| http.request(request) }
failure 'Error sending test message' unless hec_resp.code.to_s.match?(/^2/)
success 'Sent test message'
