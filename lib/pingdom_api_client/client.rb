class Client << HTTPClient
	BASE_URL = "https://api.pingdom.com/api/2.0/"
	
	attr_accessor :email, :password, :api_key, :agent_name

	def initialize(email, password, api_key, agent_name = "Pingdom API Client")
		@email = email
		@password = password
		@api_key = api_key
		super(agent_name: agent_name)
		set_auth(BASE_URL, email, password)
	end

	[:get, :post, :put, :delete].each do |method|
		eval %Q{
			def #{method}(path, query)
				web_request(:#{method}, path, query)
			end
		}
	end

	def web_request(method, path, query)
		response = send(method, BASE_URL + path, query, extheader)
		body = JSON.parse(response.body)
		unless response.code == 200
			raise(Pingdom::ApiError, "#{response.code}: #{body['error']['errormessage']}")
		end
		body
	end

	def extheader
		@extheader ||= { 'App-Key' => api_key }
	end
end
