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

require 'pry'

def stop_webdav_server
  pidfile = File.expand_path(File.dirname(__FILE__) + '/webdavserver.pid')
  pid = open(pidfile).read.strip.to_i
  Process.kill('SIGKILL', pid) rescue nil
end

def start_webdav_server(*args)
  port = args.first[:port].to_s
  base_uri = "http://localhost:#{port}/"

  server_root = Pathname.new(File.expand_path(File.dirname(__FILE__))).to_s + '/fixtures'
  %x[rm -r #{server_root}]
  %x[mkdir #{server_root}]

  if(not(server_up?(@base_uri)))
    options = {}
    # options[:username] = "davuser"
    # options[:password] = "davpass"


    # Start webdav server in subprocess
    pid = fork do
      start_dav4rack(port, server_root)
    end

    pidfile = File.expand_path(File.dirname(__FILE__) + '/webdavserver.pid')
    open(pidfile,'w') do |file|
      file.puts pid
    end

    wait_for_server(base_uri)
  else
    puts "Server is running."
  end

end

def server_up?(address)
  puts "Probing webserver #{address}:"
  begin
    return Net::HTTP.get_response(URI(address)).code == "200"
  rescue Exception => e
    puts e.to_s
    return false
  end
end

def wait_for_server(address)
  puts "waiting for #{address}"
  sleep(0.5)
  while(not(server_up?(address)))
    puts "retrying"
    sleep(0.5)
  end
end
