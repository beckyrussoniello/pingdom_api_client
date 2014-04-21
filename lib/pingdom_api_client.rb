require "httpclient"
require "json"
require "pingdom_api_client/version"
require "pingdom_api_client/helpers"
require "pingdom_api_client/client"
require "pingdom_api_client/check"

module PingdomApiClient

	class ApiError < StandardError
	end

end
