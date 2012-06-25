# Kernel extensions
# Careful monkeypatching
module Kernel
  private
  alias open_uri_and_write_original open # :nodoc:

  def open(name, *rest, &block) # :doc:
    if name.respond_to?(:open)
      name.open(*rest, &block)
    elsif name.respond_to?(:to_s) and
          name[/^(https?):\/\//] and
          rest.size > 0 and
          rest.first.to_s[/^[rwa]/]
      webdav_agent = OpenUriAndWrite::Handle.new(name, rest)
      if(block)
        yield webdav_agent
      else
        return webdav_agent
      end
    else
      open_uri_and_write_original(name, *rest, &block)
    end
  end

  module_function :open
end


