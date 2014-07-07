require 'spec_helper'

describe PingdomApiClient::Client do

    before :each do
        @email = "becky@example.com"
        @password = "password"
        @fake_api_key = "api_key_123456"
        @pingdom_config = [@email, @password, @fake_api_key]
        @pingdom_client = PingdomApiClient::Client.new(*@pingdom_config)

        @stubbed_checks = {
            "checks"=> [
                {"id"=>11111, "created"=>1398043891, "name"=>"testing1", "hostname"=>"example.com", "use_legacy_notifications"=>false, "resolution"=>5,                     "type"=>"http", "lasttesttime"=>1398057170, "lastresponsetime"=>17, "status"=>"up", "tags"=>[]},
                {"id"=>11112, "created"=>1362072988, "name"=>"testing2", "hostname"=>"domain.com", "use_legacy_notifications"=>false, "resolution"=>1,                      "type"=>"http", "lasterrortime"=>1377420319, "lasttesttime"=>1377013544, "lastresponsetime"=>30, "status"=>"paused",                        "alert_policy"=>1222222, "alert_policy_name"=>"Alert None immediately", "acktimeout"=>0, "autoresolve"=>0, "tags"=>[]}
            ]
        }
    end

    it "can use webmock" do
        @pingdom_client.class.get("https://api.pingdom.com/api/2.0/checks", {}).code.should eq(200)
    end

    describe "#web_request" do
        before :each do
            @correct_auth = {username: @email, password: @password}
            @correct_headers = {"User-Agent" => "Pingdom API Client", "App-Key" => @fake_api_key}
            @correct_options = {basic_auth: @correct_auth, headers: @correct_headers, query: {}}
            @fake_response = "fake"
            @fake_response.stub(:body).and_return(@stubbed_checks.to_json)
            @fake_response.stub(:code).and_return(200)
            @error_response = "error"
            @error_body = {error: {errormessage: "The error message"}}.to_json
            @error_response.stub(:body).and_return(@error_body)
            @error_response.stub(:code).and_return(401)
        end

        context "GET request" do
            it "calls the HTTParty #get method, with the correct parameters" do
                PingdomApiClient::Client.should_receive(:get).with("/checks", @correct_options).and_return(@fake_response)
                @pingdom_client.web_request(:get, "/checks", {})
            end

            context "200 response" do
                it "returns a parsed version of the response body" do
                    @pingdom_client.web_request(:get, "/checks", {}).should eq(@stubbed_checks)
                end
            end

            context "error response" do
                it "raises an API error with the correct error message" do
                    PingdomApiClient::Client.stub(:get).and_return(@error_response)
                    expect{
                        @pingdom_client.web_request(:get, "/checks", {})
                    }.to raise_error(PingdomApiClient::ApiError, "401: The error message")
                end
            end
        end

        context "POST request" do
            it "calls the HTTParty #post method, with the correct parameters" do
                PingdomApiClient::Client.should_receive(:post).with("/checks", @correct_options).and_return(@fake_response)
                @pingdom_client.web_request(:post, "/checks", {})
            end

            context "200 response" do
                it "returns a parsed version of the response body" do
                    @pingdom_client.web_request(:post, "/checks", {some: "stuff"}).should eq(@stubbed_checks)
                end
            end

            context "error response" do
                it "raises an API error with the correct error message" do
                    PingdomApiClient::Client.stub(:post).and_return(@error_response)
                    expect{
                        @pingdom_client.web_request(:post, "/checks", {some: "stuff"})
                    }.to raise_error(PingdomApiClient::ApiError, "401: The error message")
                end
            end
        end

        context "PUT request" do
						before :each do
							@query = {some: "stuff"}
							@correct_options[:query] = @query
						end

            it "calls the HTTParty #put method, with the correct parameters" do
                PingdomApiClient::Client.should_receive(:put).with("/checks/111111", @correct_options).and_return(@fake_response)
                @pingdom_client.web_request(:put, "/checks/111111", @query)
            end

            context "200 response" do
                it "returns a parsed version of the response body" do
                    @pingdom_client.web_request(:put, "/checks/111111", @query).should eq(@stubbed_checks)
                end
            end

            context "error response" do
                it "raises an API error with the correct error message" do
                    PingdomApiClient::Client.stub(:put).and_return(@error_response)
                    expect{
                        @pingdom_client.web_request(:put, "/checks/111111", {some: "stuff"})
                    }.to raise_error(PingdomApiClient::ApiError, "401: The error message")
                end
            end
        end

        context "DELETE request" do
						before :each do
							@query = {some: "stuff"}
							@correct_options[:query] = @query
						end

            it "calls the HTTParty #delete method, with the correct parameters" do
                PingdomApiClient::Client.should_receive(:delete).with("/checks/111111", @correct_options).and_return(@fake_response)
                @pingdom_client.web_request(:delete, "/checks/111111", @query)
            end

            context "200 response" do
                it "returns a parsed version of the response body" do
                    @pingdom_client.web_request(:delete, "/checks/111111", @query).should eq(@stubbed_checks)
                end
            end

            context "error response" do
                it "raises an API error with the correct error message" do
                    PingdomApiClient::Client.stub(:delete).and_return(@error_response)
                    expect{
                        @pingdom_client.web_request(:delete, "/checks/111111", @query)
                    }.to raise_error(PingdomApiClient::ApiError, "401: The error message")
                end
            end
        end
    end

    describe "#get_request" do
        before :each do
            @path = "/some/path"
            @query = {some: "query"}
        end

        it "calls #web_request with the correct arguments" do
            @pingdom_client.should_receive(:web_request).with(:get, @path, @query)
            @pingdom_client.get_request(@path, @query)
        end
    end

    describe "#post_request" do
        it "calls #web_request with the correct arguments" do
            @pingdom_client.should_receive(:web_request).with(:post, @path, @query)
            @pingdom_client.post_request(@path, @query)
        end
    end

    describe "#put_request" do
        it "calls #web_request with the correct arguments" do
            @pingdom_client.should_receive(:web_request).with(:put, @path, @query)
            @pingdom_client.put_request(@path, @query)
        end
    end

    describe "#delete_request" do
        it "calls #web_request with the correct arguments" do
            @pingdom_client.should_receive(:web_request).with(:delete, @path, @query)
            @pingdom_client.delete_request(@path, @query)
        end
    end

    describe "#list_all_checks" do
        before :each do
            @fake_checks = ["check1", "check2"]
            @fake_response = {"checks" => @fake_checks}
            @pingdom_client.stub(:get_request).and_return(@fake_response)
            @checks_path = "checks"
            @pingdom_client.stub(:checks_path).and_return(@checks_path)
        end

        it "calls #get_request" do
            @pingdom_client.should_receive(:get_request).and_return(@fake_response)
            @pingdom_client.list_all_checks
        end

        it "calls #checks_path" do
            @pingdom_client.should_receive(:checks_path).and_return(@checks_path)
            @pingdom_client.list_all_checks
        end

        it "passes the return value of #checks_path as the first argument to #get_request" do
            @pingdom_client.should_receive(:get_request).with do |*args|
                args[0].should eq(@checks_path)
            end
            @pingdom_client.list_all_checks
        end

        it "passes a hash as the second parameter to #get_request" do
            @pingdom_client.should_receive(:get_request).with do |*args|
                args[1].should be_an_instance_of(Hash)
            end
            @pingdom_client.list_all_checks
        end

        context "no limit or offset specified" do
            it "passes an empty query to #get_request" do
                @pingdom_client.should_receive(:get_request).with do |*args|
                    args[1].should eq({})
                end
                @pingdom_client.list_all_checks
            end
        end

        context "limit specified, but not offset" do
            it "passes a query with the limit to #get_request" do
                @pingdom_client.should_receive(:get_request).with do |*args|
                    args[1][:limit].should eq(10)
                end
                @pingdom_client.list_all_checks(limit: 10)
            end

            it "does not include an offset in the query" do
                @pingdom_client.should_receive(:get_request).with do |*args|
                    args[1].keys.size.should eq(1)
                end
                @pingdom_client.list_all_checks(limit: 10)
            end
        end

        context "offset specified, but not limit" do
            it "passes a query with the offset to #get_request" do
                @pingdom_client.should_receive(:get_request).with do |*args|
                    args[1][:offset].should eq(20)
                end
                @pingdom_client.list_all_checks(offset: 20)
            end

            it "does not include a limit in the query" do
                @pingdom_client.should_receive(:get_request).with do |*args|
                    args[1].keys.size.should eq(1)
                end
                @pingdom_client.list_all_checks(offset: 20)
            end
        end

        context "both limit and offset specified" do
            it "includes offset in the query" do
                @pingdom_client.should_receive(:get_request).with do |*args|
                    args[1][:offset].should eq(20)
                end
                @pingdom_client.list_all_checks(limit: 10, offset: 20)
            end

            it "includes limit in the query" do
                @pingdom_client.should_receive(:get_request).with do |*args|
                    args[1][:limit].should eq(10)
                end
                @pingdom_client.list_all_checks(limit: 10, offset: 20)
            end
        end

        it "returns the list of checks" do
            @pingdom_client.list_all_checks.should eq(@fake_checks)
        end
    end
end
