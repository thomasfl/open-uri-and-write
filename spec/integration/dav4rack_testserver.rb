require 'rubygems'
require 'dav4rack'
require 'dav4rack/file_resource'
# require 'unicorn'
require 'pathname'


$publish_dates = { } # Global hashmap to hold publish-dates for all resources

class DAV4Rack::Controller

  alias_method :original_proppatch, :proppatch

  # Monkeypatch the proppatch method, so we can proppatch custom properties
  def proppatch
    input = request.body.read

    req = Nokogiri::XML(input)
    # puts "PROPPATCH"
    # puts input

    publish_date = req.xpath("//publish-date","D" => "DAV").text
    if(publish_date != "")
      # puts request.path + " = " + publish_date
      $publish_dates[request.path] = publish_date
    end

    request.body.rewind
    original_proppatch
  end

end

# Custom DAV4Rack resourceclass to handle PROPPATCH
class MyResource < DAV4Rack::FileResource

  def property_names
    super << 'publish-date'
  end

  def get_property(name)
    if(name == "publish-date")
      if($publish_dates[path])
        return $publish_dates[path]
      else
        return nil
      end
    else
      super(name)
    end
  end

  # TODO: Can't figure out why this method is never called.
  def set_property(name, value)
    puts "Debug 2: setting property #{name}:#{value}"
    super(name)
  end

end


# Starts a WebDAV server using dav4rack and unicorn
def start_dav4rack(port, root)
  options = {:resource_class => MyResource, :root => root }

  app = Rack::Builder.new do
    use Rack::ShowExceptions
    # use Rack::CommonLogger  # Display all requests
    use Rack::Reloader
    use Rack::Lint
    run DAV4Rack::Handler.new(options)
  end.to_app

  runners = []

  runners << lambda do |x|
    puts 'Starting WEBrick'
    Rack::Handler::WEBrick.run(x, :Port => port)
  end

  begin
    runner = runners.shift
    runner.call(app)
  rescue LoadError
    puts 'FAILED'
    retry unless runners.empty?
  end

end

if __FILE__ == $0

  port = "3003"
  options = {}
  # options[:username] = "davuser"
  # options[:password] = "davpass"
  path = '/tmp/webdav_server_root'
  puts "Starting server in " + path
  options[:root] = path

  start_dav4rack(port, options)
end

# start_dav4rack(3003)
