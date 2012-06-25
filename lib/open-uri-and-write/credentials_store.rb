# Store credentials for later use in sesssion.

module OpenUriAndWrite

  class CredentialsStore

    def self.get_connection_for_url(url)
      hostname = URI.parse(url).host.to_s
      if(!$_webdav_credentials_pool)
        $_webdav_credentials_pool = { }
      end
      if($_webdav_credentials_pool[hostname])
        return $_webdav_credentials_pool[hostname]
      else(!$_webdav_credentials_pool[hostname])
        agent = OpenUriAndWrite::Handle.new(url, ['w'])
        $_webdav_credentials_pool[hostname] = agent.dav
        return agent.dav
      end
    end

  end

end
