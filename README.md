OpenUriAndWrite
===============

OpenUriAndWrite is an easy to use wrapper for Net::Dav, making it as easy to write to WebDAV enabled webservers as local files.

# Examples

It is possible to open an http, https URL and write to it as though it were a file:

```ruby
  open("http://www.ruby-lang.org/open_uri_and_write.html","w") {|f|
    f.puts "<h1>OpenUriAndWrite</h1>"
  }
```

Another way to do the same:

```ruby
  open("http://www.ruby-lang.org/open_uri_and_write.html","w").puts "<h1>OpenUriAndWrite</h1>"
```


Directories are created just as normally.

```ruby
  Dir.mkdir("http://www.ruby-lang.org/open_uri_and_write")
```

# Proppatch and Propfind

The only difference between files and directories stored locally and on webdav enabled servers, is the properties extra properties directories and files can have. Properties are set with proppatch() and accessed propfind().

```ruby
    File.open("http://www.ruby-lang.org/open_uri_and_write.html","w").proppatch('<o:Author>Douglas Groncki</o:Author>')
    props = Dir.propfind("http://www.ruby-lang.org") # Returns XML
```

# Interoperability with OpenURI

To not interfer with the 'open-uri' standard library, the 'open-uri-and-write' gem is only active in file modes 'w','a','w+' and 'a+':

```ruby
  open("http://www.ruby-lang.org/open_uri_and_write.html","w").puts("<h1>HTML</h1>")
```

If not any filemode is supplied, 'open-uri' is used:

```ruby
  puts open("http://www.ruby-lang.org").read
```

# Credits

  * Tanaka Akira for the inspiration taken from 'open-uri' standard library.
  * Miron Cuperman for the 'net/dav' gem used to access webdav servers.

