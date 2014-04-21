module PingdomApiClient
	class Check
		include PingdomApiClient::Helpers

		attr_accessor :client, :name, :host, :type, :paused, :resolution, :pingdom_id

		def initialize(options = {})
			options.each do |key, value|
				eval "@#{key} = value if self.respond_to?(:#{key})"
			end
		end

		def create
			query = { name: name, host: host, type: type } 

			[:resolution, :paused].each do |instance_var|
				value = send(instance_var)
				query[instance_var] = value if value
			end

			client.post_request(checks_path, query)
		end

		def self.list_all(client, limit = nil, offset = nil)
			query = {}
			[:limit, :offset].each do |param|
				value = eval param.to_s
				query[param] =  value if value
			end
			client.get_request(checks_path, query)["checks"]
		end

		def get_info
			client.get_request(check_path, "")
		end

		def modify(query)
			client.put_request(check_path, query)
		end

		def pause
			modify(paused: true)
		end

		def unpause
			modify(paused: false)
		end

		def delete!
			client.delete_request(check_path, "")
		end
	end
end
