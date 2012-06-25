# Extensions and modifications (monkeypatching) to the File class:

class File

  class << self
    alias original_delete delete
    alias original_open open
    alias original_exists? exists?
  end

  def self.exists?(name)
    if(name[/https?:\/\//])
      dav = OpenUriAndWrite::CredentialsStore.get_connection_for_url(name)
      dav.exists?(name)
    else
      self.original_exists?(name)
    end
  end

  def self.delete(names)
    filenames = []
    if(names.class == String)
      filenames << names
    elsif(names.class = Array)
      filenames = names
    end
    filenames.each do |filename|
      if(filename[/^(https?):\/\//])
        dav = OpenUriAndWrite::CredentialsStore.get_connection_for_url(filename)
        dav.delete(filename)
      else
        self.original_delete(filename)
      end
    end
  end

  def self.open(name, *rest, &block)
    if name.respond_to?(:open)
      name.open(*rest, &block)
    elsif name.respond_to?(:to_s) and name[/^(https?):\/\//] and rest.size > 0 and rest.first.to_s[/^w/]
      webdav_agent = OpenUriAndWrite::Handle.new(name, rest)
      if(block)
        yield webdav_agent
      else
        return webdav_agent
      end
    else
      self.original_open(name, *rest, &block)
    end
  end

end
