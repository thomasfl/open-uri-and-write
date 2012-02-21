require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'pry'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

# OpenUriAndWrite is an easy to use wraper for Net::Dav.

# TODO
# 1. Test at dette fortsatt virker
#    open("http://prism.library.cornell.edu/control/authBasic/authTest/",
#           :http_basic_authentication => ["test", "this"])
#
# 2. open() should returner a StringIO objekt.

require 'open-uri-and-write'
require 'open-uri'

class TestFilewatcher < Test::Unit::TestCase

  should "write to local file normally" do
    timestamp = Time.now.to_s
    filename = '/tmp/local_test_file.txt'
    file = open(filename,'w')
    file.puts timestamp
    file.close

    content = open(filename).readlines[0].strip
    assert(content == timestamp)
  end

  should "not interfer with the open-uri lib" do
    assert( open("http://folk.uio.no/thomasfl/test.txt").readlines[0].strip == "This is a test")
    webdav_url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/apollon/test.txt'
    begin
      open(webdav_url).read
      assert(false)
    rescue Exception => e
      assert(e.to_s[/401/])
    end
  end

  should "write to webdav server without block" do
    timestamp = Time.now.to_s
    webdav_url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/apollon/test.txt'
    file = open(webdav_url,'w')
    file.puts timestamp
    content = file.read.strip
    assert(content == timestamp)

    open(webdav_url,'w').puts("write-uri-test")
    assert(open(webdav_url,'w').read.strip, "write-uri-test")
  end

  should "write to webdav server with block" do
    timestamp = Time.now.to_s
    webdav_url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/apollon/test.txt'
    open(webdav_url,'w') do |file|
      file.puts timestamp
    end
    assert(open(webdav_url,'w').read.strip, timestamp)
  end


  should "open write to file with the file class and flush with close" do
    timestamp = Time.now.to_s
    webdav_url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/apollon/test.txt'
    file = File.open(webdav_url,'w')
    file.puts(timestamp)
    file.puts('XYZ')
    file.close

    assert(open(webdav_url,'w').read.strip, timestamp)
    assert(open(webdav_url,'w').read == timestamp + "\nXYZ\n") # TODO: The trailing newline should not be there
  end

  should "proppatch files" do
    article = {
      "resourcetype" => "structured-article",
      "properties" =>    {
        "title" => "Hello world!",
        "introduction" => "This is the introduction.",
        "content" => "<p>And this is the main content.</p>"
      }
    }
    webdav_url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/apollon/test.html'
    require 'json'
    file = open(webdav_url,'w')
    file.puts(article.to_json)
    http_date = Time.now.httpdate.to_s
    file.proppatch('<v:publish-date xmlns:v="vrtx">' + http_date + '</v:publish-date>')

    props = file.propfind
    published = props.xpath("//v:published", "v" => "vrtx").text
    assert(published == "true")
  end

  should "detect if file exists and delete file" do
    webdav_url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/apollon/test.txt'
    open(webdav_url,'w').puts("Test test")
    assert( File.exists?(webdav_url) )

    File.delete(webdav_url)
    assert( !File.exists?(webdav_url) )
  end

  should "append to file" do
    # TODO: reimplement 'a','a+','w+' mode etc.
    # See http://www.techotopia.com/index.php/Working_with_Files_in_Ruby
  end

  should "create and delete directory" do
    timestamp = Time.now.to_s
    webdav_url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/apollon/new_folder'
    Dir.mkdir(webdav_url)
    assert( File.exists?(webdav_url) )

    Dir.rmdir(webdav_url)
    assert( !File.exists?(webdav_url) )

    # TODO let 'delete' and 'unlink' be aliases for 'rmdir'
    # Support Dir.pwd, Dir.directory?
  end

  should "let Dir class respons to propfind and proppatch" do
    webdav_url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/apollon/'
    props = Dir.propfind(webdav_url)
    puts props.to_s
    assert(props.to_s.size > 20)
  end

  should "be able to supply username and password as parameter to open" do
    webdav_url = 'https://www-dav.usit.uio.no/om/organisasjon/web/wapp/ansatte/thomasfl/apollon/test.txt'
    file = open(webdav_url, 'w', :webdav_username => 'username', :webdav_password => 'secret')
    begin
      file.read
      assert(fail)
    rescue Exception => e
      assert(e.to_s[/401/])
    end
  end

end
