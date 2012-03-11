require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/dav4rack_testserver')

# To run:
#  $ ruby spec/integration/open-uri-and-write-spec.rb

describe "OpenUriAndWrite" do

  before(:all) do
    start_webdav_server(:port => 3003)
    @base_uri = "http://localhost:3003/"
  end

  before(:each) do
  end

  it "should write to local file normally" do
    timestamp = Time.now.to_s
    filename = '/tmp/local_test_file.txt'
    file = open(filename,'w')
    file.puts timestamp
    file.close

    open(filename).read.strip.should == timestamp
  end

  it "should write files to webdav server" do
    timestamp = Time.now.to_s
    webdav_url = @base_uri + 'webdav_test_1.txt'
    file = open(webdav_url,'w')
    file.puts timestamp
    file.close

    # use standard lib 'open-uri' to read:
    file = open(webdav_url).read.strip.should == timestamp
  end

  it "should write to files with block syntax" do
    timestamp = Time.now.to_s
    webdav_url = @base_uri + 'webdav_test_2.txt'
    open(webdav_url,'w') do |file|
      file.puts timestamp
    end

    file = open(webdav_url).read.strip.should == timestamp
  end

  it "should open write to file with the file class and flush with close" do
    timestamp = Time.now.to_s
    webdav_url = @base_uri + 'webdav_test_3.txt'
    file = File.open(webdav_url,'w')
    file.puts(timestamp)
    file.puts('XYZ')
    file.close

    open(webdav_url,'w').read.strip.should ==  timestamp + "\nXYZ"
  end

  it "should read properties of files" do
    filename = 'webdav_test_4.txt'
    webdav_url = @base_uri + filename
    open(webdav_url,'w').puts(Time.now.to_s)

    properties = open(webdav_url,'w').propfind
    displayname = properties.xpath("//d:displayname", "d" => "DAV:").text
    displayname.should == filename
  end

  it "should set properties on files" do
    filename = 'webdav_test_5.txt'
    webdav_url = @base_uri + filename
    open(webdav_url,'w').puts(Time.now.to_s)

    # properties = open(webdav_url,'w').propfind
    # property = properties.to_s[/publish-date>([^<]*)/,1]
    # puts "Prop:" + property.to_s

    publish_date = Time.now.httpdate.to_s
    open(webdav_url,'w').proppatch("<D:publish-date>#{publish_date}</D:publish-date>")
    properties = open(webdav_url,'w').propfind
    property = properties.to_s[/publish-date>([^<]*)/,1]
    # publish_date = properties.xpath("//publish-date","D" => "DAV").text

    property.should == publish_date
  end

  # TODO test authentication

  # TODO Directories
  it "should create and delete directory" do
    # timestamp = Time.now.to_s
    webdav_url = @base_uri + 'new_folder'
    Dir.mkdir(webdav_url)
    File.exists?(webdav_url).should == true

    Dir.rmdir(webdav_url)
    # File.exists?(webdav_url).should == false

    # TODO let 'delete' and 'unlink' be aliases for 'rmdir'
    # Support Dir.pwd, Dir.directory?
  end

  it "should not matter which order the rubygems 'open-uri' and 'open-uri-and-write' is loaded" do
    # http://ruby-doc.org/core-1.9.3/Object.html
    # http://stackoverflow.com/questions/335530/how-do-you-detect-that-monkey-patching-has-occurred-in-ruby
    # http://blog.sidu.in/2007/12/rubys-methodadded.html
    
  end


  it "should to handle username and password supplied as parameter to open" do
    # TODO: This is not documented!
    webdav_url = @base_uri + 'yet_another_testfile.txt'
    file = open(webdav_url, 'w', :webdav_username => 'username', :webdav_password => 'secret')
    begin
      file.read
      should fail
    rescue Exception => e
      e.to_s[/401/].should != nil
    end
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
    stop_webdav_server
  end

end
