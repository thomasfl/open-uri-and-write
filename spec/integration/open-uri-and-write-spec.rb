require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/dav4rack_testserver')

# To run:
#  $ ruby spec/integration/open-uri-and-write-spec.r

describe "OpenUriAndWrite" do

  before(:all) do
    port = "3003"
    @base_uri = "http://localhost:#{port}/"
    if(not(server_up?(@base_uri)))
      options = {}
      # options[:username] = "davuser"
      # options[:password] = "davpass"
      options[:root] = Pathname.new(File.expand_path(File.dirname(__FILE__))).parent.to_s + '/fixtures'

      # Start webdav server in subprocess
      @pid = fork do
        start_dav4rack(port, options)
      end
      exit(0) if(@pid == nil)
      wait_for_server(@base_uri)
    else
      puts "Server is running."
    end
  end

  before(:each) do
  end


  it "should be no problem to write local files" do
    timestamp = Time.now.to_s
    filename = '/tmp/local_test_file.txt'
    file = open(filename,'w')
    file.puts timestamp
    file.close

    open(filename).read.strip.should == timestamp
  end


  it "should write files to webdav server" do
    timestamp = Time.now.to_s
    webdav_url = @base_uri + 'webdav_test.txt'
    file = open(webdav_url,'w')
    file.puts timestamp
    file.close

    # use standard lib 'open-uri' to read:
    file = open(webdav_url).read.strip.should == timestamp
  end


  after(:each) do
    url = @base_uri + 'webdav_test.txt'
    if(File.exists?(url))
      File.delete(url)
    end
  end

  after(:all) do
    # File.delete(@base_uri + 'webdav_test.txt')
    # Shut down webdav server:
    # The server takes a few seconds to stop, so we just keep it running.
    # Process.kill('SIGKILL', @pid) rescue nil
  end

end
