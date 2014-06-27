module PingdomApiClient
	class Client
		include HTTParty
		include PingdomApiClient::Helpers

		base_uri "https://api.pingdom.com/api/2.0/"
	
		attr_accessor :email, :password, :api_key, :agent_name

		def initialize(email, password, api_key, agent_name = "Pingdom API Client")
			@auth = {username: email, password: password}
			@api_key = api_key
			@headers = {"User-Agent" => agent_name, 'App-Key' => api_key}
		end

		[:get, :post, :put, :delete].each do |method|
			eval %Q{
				def #{method}_request(path, query)
					web_request(:#{method}, path, query)
				end
			}
		end

		def web_request(method, path, query)
			response = self.class.send(method, path, {basic_auth: @auth, headers: @headers, query: query})
			body = JSON.parse(response.body)
			unless response.code == 200
				raise(PingdomApiClient::ApiError, "#{response.code}: #{body['error']['errormessage']}")
			end
			body
		end

		def list_all_checks(query = {}) # takes :limit and :offset
			get_request(checks_path, query)["checks"]
		end
	end
end
