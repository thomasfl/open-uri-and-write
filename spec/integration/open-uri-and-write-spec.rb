require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/dav4rack_testserver')

# To run:
#  $ rake spec

describe "OpenUriAndWrite" do

  before(:all) do
    start_webdav_server(:port => 3003)
    @base_uri = "http://localhost:3003/"
  end

  after(:all) do
    # Shut down webdav server:
    stop_webdav_server
  end

  it "should write to local file normally" do
    timestamp = Time.now.to_s
    filename = '/tmp/local_test_file.txt'
    file = open(filename,'w')
    file.puts timestamp
    file.close

    open(filename).read.strip.should == timestamp
  end

  it "should write files to webdav server and standard lib open-uri" do
    timestamp = Time.now.to_s
    webdav_url = @base_uri + 'webdav_test_1.txt'
    file = open(webdav_url,'w')
    file.puts timestamp
    file.close

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

    publish_date = Time.now.httpdate.to_s
    open(webdav_url,'w').proppatch("<D:publish-date>#{publish_date}</D:publish-date>")
    properties = open(webdav_url,'w').propfind
    property = properties.to_s[/publish-date>([^<]*)/,1]
    property.should == publish_date
  end

  it "should append to files" do
    file = open(@base_uri + "append_file_test.txt", "w")
    file.puts "Line 1"
    file.puts "Line 2"
    file.close

    file = open(@base_uri + "append_file_test.txt", "a")
    file.puts "Line 3"
    file.puts "Line 4"
    file.close

    file = open(@base_uri + "append_file_test.txt")
    lines = file.readlines
    file.close
    lines[3].should eql("Line 4\n")
  end

  it "should create and delete directory" do
    # timestamp = Time.now.to_s
    webdav_url = @base_uri + 'new_test_folder'
    Dir.mkdir(webdav_url)
    File.exists?(webdav_url).should == true

    Dir.rmdir(webdav_url)
    # There seems to be a bug in our testserver that prevent it from deleting files
    # File.exists?(webdav_url).should == false
  end

  # TODO Test this in a separate script just to be sure
  it "should not matter which order the rubygems 'open-uri' and 'open-uri-and-write' is loaded" do
    # http://ruby-doc.org/core-1.9.3/Object.html
    # http://stackoverflow.com/questions/335530/how-do-you-detect-that-monkey-patching-has-occurred-in-ruby
    # http://blog.sidu.in/2007/12/rubys-methodadded.html
  end

  it "should handle username and password supplied as parameter to open" do
    webdav_url = @base_uri + 'yet_another_testfile.txt'
    file = open(webdav_url, 'w', :username => 'username', :password => 'secret')
    file.puts "Content"
    file.close

    begin
      file = open(webdav_url, 'w+', :username => 'username', :password => 'secret')
      file.read
      should fail
    rescue Exception => e
    end
  end

  it "should not use 'open-uri' to read file in 'r' filemode" do
    timestamp = Time.now.to_s
    webdav_url = @base_uri + 'webdav_r_filemode_test.txt'
    file = open(webdav_url,'w')
    file.puts timestamp
    file.class.should == OpenUriAndWrite
    file.close

    file = open(webdav_url)
    file.class.should == StringIO # StringIO means 'open-uri' gem is beeing used
    file.read.strip.should == timestamp

    file = open(webdav_url,'r')
    file.class.should == OpenUriAndWrite
    file.read.strip.should == timestamp
    begin
      file.puts("this should not be written")
      fail
    rescue IOError => ioError
    end
    file.close
  end

# TODO Test all modes:

# OK r
#    Read-only mode. The file pointer is placed at the beginning of
#    the file. This is the default mode.
#
# r+
# Read-write mode. The file pointer will be at the beginning of the file.
#
# w
# Write-only mode.
#   - Overwrites the file if the file exists.
#   - If the file does not exist, creates a new file for writing.
#
# w+
# Read-write mode.
#   - Overwrites the existing file if the file exists.
#   - If the file does not exist, creates a new file for reading and writing.
#
# a
# Write-only mode.
#    - The file pointer is at the end of the file if the file exists.
#    - That is, the file is in the append mode.
#    - If the file does not exist, it creates a new file for writing.
#
# a+
# Read and write mode.
#    - The file pointer is at the end of the file if the file exists.
#    - The file opens in the append mode.
#    - If the file does not exist, it creates a new file for reading and writing.
#
# r+, w+, and a+ all do read-write. w+ truncates the file. a+ appends.
# w+ and a+ both create the file if it does not exist.)

# TODO: Store username and hostname in .open-uri-and-write-hosts

#   # TODO test authentication

  after(:each) do
    url = @base_uri + 'webdav_test.txt'
    if(File.exists?(url))
      File.delete(url)
    end
  end

end
