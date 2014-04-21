class Check
	attr_accessor :client, :name, :host, :type, :paused, :resolution

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

		client.post_request("checks", query)
	end
end
