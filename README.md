OpenUriAndWrite
===============

OpenUriAndWrite is an easy to use wrapper for Net::Dav, making it as easy to write to WebDAV enabled webservers as local files.

# Disclaimer

This is work in progress. You can write files and crate directories, but there's still work to do on reading directories and at the time one filemodes "w" and "a" is supported.

Examples
--------

It is possible to open an http/https URL and write to it as though it were a local file:

```ruby
  open("http://www.ruby-lang.org/open_uri_and_write.html","w") {|f|
    f.puts "<h1>OpenUriAndWrite</h1>"
  }
```

With method chaining it gets more compact:

```ruby
  open("http://www.ruby-lang.org/open_uri_and_write.html","w").puts "<h1>OpenUriAndWrite</h1>"
```

Files can be deleted as local files:

```ruby
  File.delete("http://www.ruby-lang.org/open_uri_and_write.html")
```

Directories are created the same way as local files:

```ruby
  Dir.mkdir("http://www.ruby-lang.org/open_uri_and_write")
```

Authentication
--------------

By default 'open-uri-and-write' will prompt for username and password when executing scripts:

```
  $ ruby webdav_test.rb
  Username for www.example.com: scott
  Password for 'scott@www.example.com: *****
```

Credentials can be supplied with the DAVUSER and DAVPASS environment variables.

```
  $ export DAVUSER=scott
  $ export DAVPASS=tiger
  $ ruby webdav_test.rb
```

```ruby
  ENV['DAVUSER'] = 'scott'
  ENV['DAVPASS'] = 'tiger'
```

Another option is to supply username and password as arguments to open:

```ruby
   file = open('https://www.example.com/', 'w', :username => 'scott', :password => 'tiger')
```

On OS X passwords typed in by the user will be stored encrypted in the Keychain and reused later.

```
  $ export DAVUSER=scott
  $ ruby webdav_test.rb
  Password for 'scott@www.example.com': *****
  Password for 'scott@www.example.com' stored on OS X KeyChain.
```

The next time this script is executed, it will not prompt for password.

Proppatch and Propfind
----------------------

The only difference between local files and directories and remote files and directories on webdav servers, is that they both can have an infinite amount of properties. Properties are set as a xml snippet with proppatch() and accessed with propfind().

```ruby
    file = File.open('http://www.ruby-lang.org/open_uri_and_write.html','w')
    file.proppatch('<D:Author>Thomas Flemming</D:Author>')
    properties_as_xml = Dir.propfind("http://www.ruby-lang.org")
```

Interoperability with OpenURI
-----------------------------

If no filemode is specified when using open on url, standard 'open-uri' will be used.

```ruby
  puts open("http://www.ruby-lang.org").read()  # Use 'open-uri'
  open('http://www.ruby-lang.org/my_page.html','w').puts("<h1>HTML</h1>") # Use 'open-uri-and-write'
```

To not interfer with the 'open-uri' standard library, the 'open-uri-and-write' gem is only active in file modes 'w','a','w+','a+' and 'r+'.

File access modes
===========================



r
Read-only mode. The file pointer is placed at the beginning of the file. This is the default mode.

r+
Read-write mode. The file pointer will be at the beginning of the file.

w
Write-only mode. Overwrites the file if the file exists. If the file does not exist, creates a new file for writing.

w+
Read-write mode. Overwrites the existing file if the file exists. If the file does not exist, creates a new file for reading and writing.

a
Write-only mode. The file pointer is at the end of the file if the file exists. That is, the file is in the append mode. If the file does not exist, it creates a new file for writing.

a+
Read and write mode. The file pointer is at the end of the file if the file exists. The file opens in the append mode. If the file does not exist, it creates a new file for reading and writing.

(empshasis mine.)

r+, w+, and a+ all do read-write. w+ truncates the file. a+ appends. w+ and a+ both create the file if it does not exist.)
```

Install
-------

```
  $ gem install open-uri-and-write
```

Testing
-------
To run all tests:

```
  $ rake spec
```

The tests will start a webserver with webdav at startup, and close it down before finishing.

Credits
-------

  * Tanaka Akira for the inspirational ['open-uri'](https://github.com/ruby/ruby/blob/trunk/lib/open-uri.rb) standard ruby library.
  * Miron Cuperman for the ['net/dav'](https://github.com/devrandom/net_dav) gem used to access webdav servers.

Author
------

Thomas Flemming

  * [@thomasfl](https://twitter.com/#!/thomasfl)
  * [http://github.com/thomasfl/](http://github.com/thomasfl/)
