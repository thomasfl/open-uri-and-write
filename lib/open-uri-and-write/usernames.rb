# For storing usernames and hostnames in ~/.open-uri-and-write-usernames

module OpenUriAndWrite

  class Usernames

    def homedir
      if(Dir.respond_to?("home"))
        Dir.home
      else
        File.expand_path("~")
      end
    end

    def usernamesfile
      homedir + "/.open-uri-and-write-usernames"
    end

    def read_usernames_and_hosts
      usernames = {}
      if(File.exist?(usernamesfile))
        open(usernamesfile).readlines.each do |line|
          username, host = line.split(':')
          usernames[host.strip] = username.strip
        end
      end
      return usernames
    end

    def save_username_and_host(username,host)
      usernames = read_usernames_and_hosts
      usernames[host] = username
      store_username_and_host(usernames)
    end

    def store_username_and_host(usernames)
      file = open(usernamesfile, "w")
      usernames.keys.each do |key|
        file.puts "#{usernames[key]}:#{key}"
      end
      file.close
    end

    def username_for_host(host)
      usernames = read_usernames_and_hosts
      return usernames[host]
    end

  end
end

