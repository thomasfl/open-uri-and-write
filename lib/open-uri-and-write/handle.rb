# OpenUriAndWrite file handler. Does authentication upon initialize

module OpenUriAndWrite

  class Handle < StringIO

    alias_method :original_puts, :puts
    attr_accessor :dav, :filemode

    def initialize(url, rest)
      super("")
      @url = url
      @uri = URI.parse(url)
      if(rest.size > 0)
        @filemode = rest.first.to_s
        if(@filemode[/^[rwa]/])
          @dav = Net::DAV.new(@url)
          options = rest[1]
          if(options && options[:username] && options[:password])
            @dav.credentials(options[:username], options[:password])
          else
            set_credentials
          end
        end

        if(@filemode[/^a/])
          write(@dav.get(@url)) # Write to StringIO
        end

      end
    end

    def set_credentials
      if(ENV['DAVUSER'])
        username = ENV['DAVUSER']
      else
        usernames = OpenUriAndWrite::Usernames.new()
        username = usernames.username_for_host(@uri.host)
        if(not(username))
          username = ask("Username for #{@uri.host}: ")
          usernames.save_username_and_host(username,@uri.host)
          STDOUT.puts "Username and hostname stored in #{usernames.usernamesfile}"
        end
      end

      password = nil
      if(ENV['DAVPASS'])
        password = ENV['DAVPASS']
      else
        osx = (RUBY_PLATFORM =~ /darwin/)
        osx_keychain = false
        if(osx)
          begin
            require 'keychain'
            osx_keychain = true
          rescue LoadError
          end
        end
        if(osx_keychain)then
          item = Keychain.items.find { |item| item.label =~ /#{@uri.host}/ }
          if(item)
            password = item.password
          end

          if(!password)
            password = ask("Password for '#{username}@#{@uri.host}: ") {|q| q.echo = "*"}
            Keychain.add_internet_password(@uri.host, '', username, '', password)
            STDOUT.puts "Password for '#{username}@#{@uri.host}' stored on OSX KeyChain."
          end

        else
          password = ask("Password for '#{username}@#{@uri.host}: ") {|q| q.echo = "*"}
        end
      end
      @dav.credentials(username, password)
    end

    def puts(string)
      if(@filemode[/^r/])
        raise IOError.new(true), "not opened for writing"
      end

      super(string)
      @dav.put_string(@url, string)
    end

    def read
      @dav.get(@url)
    end

    def proppatch(xml_snippet)
      @dav.proppatch(@uri, xml_snippet)
    end

    def propfind
      @dav.propfind(@url)
    end

    def close
      @dav.put_string(@url, string)
    end

  end

end

