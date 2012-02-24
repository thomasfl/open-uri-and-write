require 'rubygems'
require 'dav4rack'
require 'unicorn'
require 'pathname'

# Starts a WebDAV server using dav4rack and unicorn
def start_dav4rack(port, options)

  app = Rack::Builder.new do
    use Rack::ShowExceptions
    # use Rack::CommonLogger  # Display all requests
    use Rack::Reloader
    use Rack::Lint
    run DAV4Rack::Handler.new(options)
  end.to_app

  runners = []
  runners << lambda do |x|
    print 'Looking for unicorn... '
    require 'unicorn'
    puts 'OK'
    if(Unicorn.respond_to?(:run))
      puts "Pid 1: #{Process.pid}"
      Unicorn.run(x, :listeners => ["0.0.0.0:#{port}"])
    else
      puts "Pid 2: #{Process.pid}"
      Unicorn::HttpServer.new(x, :listeners => ["0.0.0.0:#{port}"]).start.join
    end
  end

  begin
    puts "Pid 3: #{Process.pid}"
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
  puts Pathname.new(File.expand_path(File.dirname(__FILE__))).parent.to_s + '/fixtures'
  options[:root] = File.expand_path(File.dirname(__FILE__)) + '/fixtures'

end

# start_dav4rack(3003)
