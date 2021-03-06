$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'open-uri-and-write'
require 'rspec'
require 'net/http'
require 'uri'
require 'pathname'
require 'nokogiri'
require 'pry'


ENV['DAVUSER'] = 'dummy'
ENV['DAVPASS'] = 'dummy'

RSpec.configure do  |config|
end

def stop_webdav_server
  Process.kill('SIGKILL', $pid) rescue nil
end

def start_webdav_server(*args)
  port = args.first[:port].to_s
  @base_uri = "http://localhost:#{port}/"

  server_root = '/tmp/open_uri_and_write_test'
  %x[rm -r #{server_root}]
  %x[mkdir #{server_root}]

  if(not(server_up?(@base_uri)))
    options = {}

    # Start webdav server in subprocess
    $pid = fork do
      start_dav4rack(port, server_root)
    end

    wait_for_server(@base_uri)
  else
    puts "Server is running."
  end

end

def server_up?(address)
  begin
    return Net::HTTP.get_response(URI(address)).code == "200"
  rescue Exception => e
    puts e.to_s
    return false
  end
end

def wait_for_server(address)
  puts "Waiting for WebDAV server to start#{address}"
  sleep(0.5)
  while(not(server_up?(address)))
    puts "retrying"
    sleep(0.5)
  end
end
