require 'securerandom'

id = SecureRandom.uuid

`curl -s 'http://localhost:4567/register' --data 'first_name=Troll&last_name=Face#{id}'`
splunk_messages = `curl -s -k -u admin:correcthorsebatterystaple https://localhost:8089/services/messages`

if splunk_messages.include?(id)
  puts "[PASS] Troll user successfully logged with id " + id
else
  puts "[FAIL] No logging, can't find Troll user with id " + id
end
