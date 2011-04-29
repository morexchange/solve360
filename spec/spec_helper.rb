require 'rubygems'
require 'json'
require 'rest_client'

require File.join(File.dirname(__FILE__), '..', 'lib', 'solve360')

Solve360::Config.configure YAML::load(File.read(File.join(File.dirname(__FILE__), 'api_settings.yml')))

def file_fixture(filename)
  open(File.join(File.dirname(__FILE__), 'fixtures', "#{filename.to_s}")).read
end
 
def stub_http_response_with(filename)
  format = filename.split('.').last.intern
  data = file_fixture(filename)
  
  header = Net::HTTPResponse.new(1.0, 200, 'OK')
  header.add_field 'Content-type', 'application/json'
  response = RestClient::Response.create(JSON.parse(data), header, nil)
  
  http_request = HTTParty::Request.new(Net::HTTP::Get, 'http://localhost', :format => format)
  http_request.stub!(:perform).and_return(response)
  
  HTTParty::Request.stub!(:new).and_return(http_request)
end