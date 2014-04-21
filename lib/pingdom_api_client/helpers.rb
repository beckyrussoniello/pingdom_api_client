module PingdomApiClient
	module Helpers
		def self.included(base)
			base.extend Helpers
			base.send(:include, InstanceMethods)
		end

		module InstanceMethods
			def check_path
				"checks/#{pingdom_id}"
			end
		end

		def checks_path
			"checks"
		end
	end
end
