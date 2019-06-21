#!/usr/bin/env ruby
require 'net/http'
require 'uri'

APP_URL    = ENV.fetch('APP_URL')
IDENTIFIER = ENV.fetch('IDENTIFIER')

puts 'Making request'
user_resp = Net::HTTP.post_form(
  URI("#{APP_URL}/register"),
  first_name: 'Smoke-01',
  last_name: "#{IDENTIFIER}-#{Time.now.to_i}"
)
puts 'Finished'
abort "Received #{user_resp.code}" unless user_resp.code.to_s.match?(/^2/)
uuid = user_resp.body[/(\h{8}-\h{4}-\h{4}-\h{4}-\h{12})/,1]
puts "Found receipt #{uuid}"
