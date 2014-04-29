require 'bundler/setup'
Bundler.setup

require 'pingdom_api_client'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

stubbed_checks_json = "{\"checks\":[{\"id\":11111,\"created\":1398043891,\"name\":\"testing1\",\"hostname\":\"example.com\",\"use_legacy_notifications\":false,\"resolution\":5,\"type\":\"http\",\"lasttesttime\":1398057170,\"lastresponsetime\":17,\"status\":\"up\",\"tags\":[]},{\"id\":11112,\"created\":1362072988,\"name\":\"testing2\",\"hostname\":\"domain.com\",\"use_legacy_notifications\":false,\"resolution\":1,\"type\":\"http\",\"lasterrortime\":1377420319,\"lasttesttime\":1377013544,\"lastresponsetime\":30,\"status\":\"paused\",\"alert_policy\":1222222,\"alert_policy_name\":\"Alert None immediately\",\"acktimeout\":0,\"autoresolve\":0,\"tags\":[]}]}"

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /pingdom/).
      to_return(status: 200, body: stubbed_checks_json, headers: {})
  end
end


