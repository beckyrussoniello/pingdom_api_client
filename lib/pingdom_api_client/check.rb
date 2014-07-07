module PingdomApiClient
	class Check
		include PingdomApiClient::Helpers

		attr_accessor :client, :name, :host, :type, :paused, :resolution, :pingdom_id,
			:sendnotificationwhendown, :sendtoemail

		def initialize(client, options = {})
			@client = client

			options.each do |key, value|
				eval "@#{key} = value if self.respond_to?(:#{key})"
			end
		end

		def upload
			validate_attributes_for_upload
			query = { name: name, host: host, type: type }

			[:resolution, :paused, :sendnotificationwhendown, :sendtoemail].each do |instance_var|
				value = send(instance_var)
				query[instance_var] = value if value
			end

			response = client.post_request(checks_path, query)
			unless response["check"] && response["check"]["id"]
				raise(PingdomApiClient::ApiError, "Unexpected response body")
			end
			
			response
		end

		def get_info
			client.get_request(check_path, "")
		end

		def outage_report(start_time)
			query = { from: start_time.to_i, order: 'asc'}
			path = "summary.outage/#{pingdom_id}"
			client.get_request(path, query)["summary"]["states"]
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

		def assign_to_alert_policy(alert_policy_id)
			query = { alert_policy: alert_policy_id, use_legacy_notifications: false }
			modify(query)
		end

		def delete!
			client.delete_request(check_path, "")
		end

		def check_path
			validate_pingdom_id_present
			"checks/#{pingdom_id}"
		end

		private

		def validate_attributes_for_upload
			if [name, host, type].include? nil
				raise AttributesMissing, "You must set the name, host, and type before uploading a new check to Pingdom."
			end
		end

		def validate_pingdom_id_present
			raise(AttributesMissing, "Pingdom id cannot be nil") unless pingdom_id
		end

		class AttributesMissing < StandardError
		end
	end
end
