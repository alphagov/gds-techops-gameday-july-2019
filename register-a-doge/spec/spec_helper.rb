require 'rack/test'
require 'timecop'

require_relative '../register-a-doge'

module RackTest
 include Rack::Test::Methods

 def app
   Sinatra::Application
 end

end

RSpec.configure do |config|
  config.include RackTest

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
