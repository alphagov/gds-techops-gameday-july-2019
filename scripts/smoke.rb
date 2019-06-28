#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'digest'
APP_URL    = ENV.fetch('APP_URL')
IDENTIFIER = ENV.fetch('IDENTIFIER')
DIFFICULTY = ENV.fetch('APP_DIFFICULTY', 1)

puts '[*] Making request'
first_name = 'Smoke-01'
last_name = "#{IDENTIFIER}-" + Time.now.to_i.to_s

user_resp = Net::HTTP.post_form(
  URI("#{APP_URL}/register"),
  first_name: first_name,
  last_name: last_name
)
puts '[+] Finished'

abort "[*] Received #{user_resp.code}" unless user_resp.code.to_s.match?(/^2/)

sha2 = user_resp.body[/(\h{64})/, 1]
code = user_resp.body[/x(\d+)x/, 1]
puts "[*] Found receipt #{sha2}"
puts "[*] Found code #{code}"

expected = Digest::SHA2.hexdigest "#{first_name}#{last_name}#{code}"

if sha2 != expected
  puts "[!] Receipt is bad!"
  exit 1
end

unless sha2.hex.to_s(2).rjust(sha2.size*4, '0').starts_with?('0' * DIFFICULTY)
  puts "[!] Reciept is not difficult enough!"
  exit 2
end

puts "[+] Receipt is good!"
