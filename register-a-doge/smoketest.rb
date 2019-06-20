require 'securerandom'
require 'json'

id = SecureRandom.uuid

`curl -s 'http://localhost:4567/register' --data 'first_name=Troll&last_name=Face#{id}'`

search_response = `curl -s -k -u 'admin:correcthorsebatterystaple' https://localhost:8089/services/search/jobs  -d search="search source=\"testlog\"" -d output_mode=json`

search_id = JSON.parse(search_response)["sid"]

puts "Waiting for the search to complete..."
sleep 1
puts "...OK"

splunk_messages = `curl -s -k -u 'admin:correcthorsebatterystaple' https://localhost:8089/services/search/jobs/#{search_id}/results/ --get -d output_mode=json`

if splunk_messages.include? id
  puts "[PASS] Troll user successfully logged with id " + id
else
  puts "[FAIL] Can't find Troll user registered in splunk with id " + id
end
