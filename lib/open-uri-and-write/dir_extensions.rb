# Extensions and modifications (monkeypatching) to the Dir class:

class Dir

  class << self
    alias original_mkdir mkdir
    alias original_rmddir rmdir
  end

  def self.mkdir(name, *args)
    if name.respond_to?(:to_s) and name[/^(https?):\/\//]
      dav = OpenUriAndWrite::CredentialsStore.get_connection_for_url(name)
      dav.mkdir(name)
    else
      self.original_mkdir(name, *args)
    end
  end

  def self.rmdir(name)
    if name.respond_to?(:to_s) and name[/^(https?):\/\//]
      dav = OpenUriAndWrite::CredentialsStore.get_connection_for_url(name)
      dav.delete(name)
    else
      self.original_rmdir(name)
    end
  end

  def self.propfind(name)
    if name.respond_to?(:to_s) and name[/^(https?):\/\//]
      dav = OpenUriAndWrite::CredentialsStore.get_connection_for_url(name)
      dav.propfind(name)
    else
      raise IOError.new(true), "Illegal action: Can't do propfind #{name}"
    end
  end

  def self.proppatch(name,xml_snippet)
    if name.respond_to?(:to_s) and name[/^(https?):\/\//]
      dav = OpenUriAndWrite::CredentialsStore.get_connection_for_url(name)
      dav.propfind(name, xml_snippet)
    else
      raise IOError.new(true), "Illegal action: Can't do proppatch on #{name}"
    end
  end

end
