`curl -s 'http://localhost:4567/register' --data 'first_name=Troll&last_name=Face'`
splunk_messages = `curl -s -k -u admin:correcthorsebatterystaple https://localhost:8089/services/messages`

if splunk_messages.include?('Troll')
  puts '[PASS] Troll user successfully logged'
else
  puts '[FAIL] No logging'
end
