require 'spec_helper'

describe PingdomApiClient::Check do
	before :each do
		@pingdom_config = [@email, @password, @fake_api_key]
		@client = PingdomApiClient::Client.new(*@pingdom_config)
		@options = {name: "the name", host: "the host", type: "regular"}
		@check = PingdomApiClient::Check.new(@client, @options)
		@fake_check_path = "/check/11111"
		@check.stub(:check_path).and_return(@fake_check_path)
	end

	describe "#initialize" do
		it "sets @client to the value of the first argument" do
			@check = PingdomApiClient::Check.new(@client)
			@check.client.should eq(@client)
		end

		context "no options passed in" do
			before :each do
				@check = PingdomApiClient::Check.new(@client)
			end

			it "does not set a name attribute" do
				@check.name.should be_nil
			end
		end

		context "two valid options passed in" do
			before :each do
				@options = {name: "the name", paused: true}
				@check = PingdomApiClient::Check.new(@client, @options)
			end

			it "sets the first attribute" do
				@check.name.should eq("the name")
			end

			it "sets the second attribute" do
				@check.paused.should be_true
			end
		end

		context "some invalid options passed in" do
			before :each do
				@options = {name: "the name", invalid: "invalid"}
				@check = PingdomApiClient::Check.new(@client, @options)
			end

			it "still sets any valid options" do
				@check.name.should eq("the name")
			end

			it "ignores invalid options" do
				@check.instance_variable_get(:@invalid).should be_nil
			end

			it "does not raise an error" do
				expect{ 
					@check = PingdomApiClient::Check.new(@client, @options) 
				}.to_not raise_error
			end
		end
	end

	describe "#upload" do
		before :each do
			@expected_response = { "check" => { "id" => 123456 }}
			@client.stub(:post_request).and_return(@expected_response)
		end

		it "calls #validate_attributes_for_upload" do
			@check.should_receive(:validate_attributes_for_upload)
			@check.upload
		end

		it "it POSTs to the Pingdom API" do
			@client.should_receive(:post_request)
			@check.upload
		end

		it "calls #checks_path" do
			@check.should_receive(:checks_path)
			@check.upload
		end

		it "passes the return value of #checks_path as the first argument to #post_request" do
			@check.stub(:checks_path).and_return("checks")
			@client.should_receive(:post_request).with do |*args|
				args[0].should eq("checks")
			end
			@check.upload
		end

		context "missing required attributes" do
			before :each do
				@error_msg = "You must set the name, host, and type before uploading a new check to Pingdom."
			end

			it "raises an error if name is missing" do
				@check.name = nil
				expect{ 
					@check.upload 
				}.to raise_error(PingdomApiClient::Check::AttributesMissing, @error_msg)
			end

			it "raises an error if host is missing" do
				@check.host = nil
				expect{ 
					@check.upload 
				}.to raise_error(PingdomApiClient::Check::AttributesMissing, @error_msg)
			end

			it "raises an error if type is missing" do
				@check.type = nil
				expect{ 
					@check.upload 
				}.to raise_error(PingdomApiClient::Check::AttributesMissing, @error_msg)
			end
		end

		context "@resolution and @paused are not set" do
			it "does not include :resolution or :paused in query hash" do
				@client.should_receive(:post_request).with do |*args|
					(args[1].keys & [:resolution, :paused]).should be_empty
				end
				@check.upload
			end
		end

		context "@resolution is set" do
			before :each do
				@check.resolution = 1
			end

			it "includes :resolution in the query hash" do
				@client.should_receive(:post_request).with do |*args|
					args[1][:resolution].should eq(1)
				end
				@check.upload
			end
		end

		context "@paused is set" do
			before :each do
				@check.paused = true
			end

			it "includes :paused in the query hash" do
				@client.should_receive(:post_request).with do |*args|
					args[1][:paused].should be_true
				end
				@check.upload
			end
		end

		context "@resolution and @paused are both set" do
			before :each do
				@check.resolution = 1
				@check.paused = true
			end

			it "does includes :resolution and :paused in query hash" do
				@client.should_receive(:post_request).with do |*args|
					(args[1].keys & [:resolution, :paused]).should eq([:resolution, :paused])
				end
				@check.upload
			end
		end

		context "unexpected response body" do
			before :each do
				@client.stub(:post_request).and_return({something: "else"})
			end

			it "raises an error" do
				expect{
					@check.upload
				}.to raise_error(PingdomApiClient::ApiError, "Unexpected response body")
			end
		end
	end

	describe "#get_info" do
		before :each do
			@client.stub(:get_request)
		end

		it "calls #check_path" do
			@check.should_receive(:check_path)
			@check.get_info
		end

		it "makes a GET request" do
			@client.should_receive(:get_request)
			@check.get_info
		end

		it "passes the return value of #check_path as the first argument to #get_request" do
			@client.should_receive(:get_request).with do |*args|
				args[0].should eq(@fake_check_path)
			end
			@check.get_info
		end

		it "passes an empty string as the second argument to #get_request" do
			@client.should_receive(:get_request).with do |*args|
				args[1].should eq("")
			end
			@check.get_info
		end
	end

	describe "#modify" do
		before :each do
			@client.stub(:put_request)
		end

		it "calls #check_path" do
			@check.should_receive(:check_path).and_return(@fake_check_path)
			@check.modify({})
		end

		it "makes a PUT request" do
			@client.should_receive(:put_request)
			@check.modify({})
		end

		it "passes the return value of #check_path as the first argument to #put_request" do
			@client.should_receive(:put_request).with do |*args|
				args[0].should eq(@fake_check_path)
			end
			@check.modify({})
		end

		it "passes the query as the second argument to #put_request" do
			query = {paused: true}
			@client.should_receive(:put_request).with do |*args|
				args[1].should eq(query)
			end
			@check.modify(query)
		end
	end

	describe "#pause" do
		before :each do
			@query = {paused: true}
		end

		it "calls #modify, passing in {paused: true}" do
			@check.should_receive(:modify).with(@query)
			@check.pause
		end
	end

	describe "#unpause" do
		before :each do
			@query = {paused: false}
		end

		it "calls #modify, passing in {paused: true}" do
			@check.should_receive(:modify).with(@query)
			@check.unpause
		end
	end

	describe "#assign_to_alert_policy" do
		before :each do
			@alert_policy_id = 12345
		end

		it "calls #modify, passing in the alert policy id" do
			@check.should_receive(:modify).with do |*args|
				args[0][:alert_policy].should eq(@alert_policy_id)
			end
			@check.assign_to_alert_policy(@alert_policy_id)
		end

		it "does not use legacy notifications" do
			@check.should_receive(:modify).with do |*args|
				args[0][:use_legacy_notifications].should be_false
			end
			@check.assign_to_alert_policy(@alert_policy_id)
		end
	end

	describe "#delete!" do
		before :each do
			@client.stub(:delete_request)
		end

		it "calls #check_path" do
			@check.should_receive(:check_path).and_return(@fake_check_path)
			@check.delete!
		end

		it "makes a DELETE request" do
			@client.should_receive(:delete_request)
			@check.delete!
		end

		it "passes the return value of #check_path as the first argument to #put_request" do
			@client.should_receive(:delete_request).with do |*args|
				args[0].should eq(@fake_check_path)
			end
			@check.delete!
		end

		it "passes an empty string as the second argument to #get_request" do
			@client.should_receive(:delete_request).with do |*args|
				args[1].should eq("")
			end
			@check.delete!
		end
	end

	describe "check_path" do
		before :each do
			@check = PingdomApiClient::Check.new(@client, @options)
			@check.pingdom_id = "111111"
		end

		it "calls #validate_pingdom_id_present" do
			@check.should_receive(:validate_pingdom_id_present)
			@check.check_path
		end

		context "pingdom_id not set" do
			it "raises an error" do
				@check.pingdom_id = nil
				expect{
					@check.check_path
				}.to raise_error(PingdomApiClient::Check::AttributesMissing, "Pingdom id cannot be nil")
			end
		end
	end
end
