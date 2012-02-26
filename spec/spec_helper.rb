$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'open-uri-and-write'
require 'spec'
require 'spec/autorun'
require 'net/http'
require 'uri'
require 'pathname'
require 'nokogiri'

ENV['DAVUSER'] = 'dummy'
ENV['DAVPASS'] = 'dummy'

Spec::Runner.configure do |config|

end

def server_up?(address)
  begin
    # puts "testing #{address}:" + Net::HTTP.get_response(URI(address)).code
    # print "."
    # return Net::HTTP.get_response(URI(address)).code.to_i > 0
    return Net::HTTP.get_response(URI(address)).code == "200"
  rescue
    return false
  end
end

def wait_for_server(address)
  sleep(0.1)
  while(not(server_up?(address)))
    sleep(0.1)
  end
end
