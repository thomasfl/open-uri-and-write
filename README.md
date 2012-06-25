OpenUriAndWrite
===============

OpenUriAndWrite is an easy to use wrapper for Net::Dav, making it as easy to write to WebDAV enabled webservers.

Examples
--------

It is possible to open an http/https URL and write to it as though it were a local file:

```ruby
  require 'rubygems'
  require 'open-uri-and-write'

  open("http://www.ruby-lang.org/open_uri_and_write.html","w") {|f|
    f.puts "<h1>OpenUriAndWrite</h1>"
  }
```

Delete files on webserver:

```ruby
  File.delete("http://www.ruby-lang.org/open_uri_and_write.html")
```

Create directory on web server:

```ruby
  Dir.mkdir("http://www.ruby-lang.org/open_uri_and_write")
```

Install
-------

```
  $ gem install open-uri-and-write
```

OSX users that wishes to store passwords on the keychain need to install this in addition:

```
  $ gem install keychain_services
```


Authentication
--------------
By default the scripts prompts the user for username and password. The username and hostname are stored in the file ~/.open-uri-and-write-usernames, so the next time only the password has to be typed in. On OSX the password is stored encrypted in the keychain.

Credentials can also supplied as environment variables or options.

Default behaviour if no username or password is set:

```
  $ ruby webdav_test.rb
  Username for www.example.com: scott
  Password for 'scott@www.example.com: *****
  Username and hostname stored in /Users/thomasf/.open-uri-and-write-usernames

  $ ruby webdav_test.rb
  Password for 'scott@www.example.com: *****
```

Supplying credentials with the DAVUSER and DAVPASS environment variables:

```
  $ export DAVUSER=scott
  $ export DAVPASS=tiger
  $ ruby webdav_test.rb
```

Setting username and password in ruby:

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

The next time this script is executed, it will not prompt for username and password.

Note that if you have stored a misspelled password on the OSX Keychain, then you will have to delete it manually with Keychain Access application.

Proppatch and Propfind
----------------------

In difference to files and directories on local filesystems, files and directories on WebDAV servers can have many custom properties. Properties can be read with til propfindare set as a xml snippet with proppatch() and accessed with propfind().

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

Supported file access modes
===========================

 * r Read-only mode. The file pointer is placed at the beginning of the file. This is the default mode.

 * w Write-only mode. Overwrites the file if the file exists. If the file does not exist, creates a new file for writing.

 * a Write-only mode. The file pointer is at the end of the file if the file exists. That is, the file is in the append mode. If the file does not exist, it creates a new file for writing.

Unspported file access modes
============================
 * r+ Read-write mode. The file pointer will be at the beginning of the file.

 * w+ Read-write mode. Overwrites the existing file if the file exists. If the file does not exist, creates a new file for reading and writing.

 * a+ Read and write mode. The file pointer is at the end of the file if the file exists. The file opens in the append mode. If the file does not exist, it creates a new file for reading and writing.

Testing
-------
To run all tests:

```
  $ rake spec
```

The tests will start a webserver with webdav at startup, and close it down before finishing.

Future work
-----------
This is work in progress. You can write files and crate directories, but there's still work to do on reading directories and at the time one filemodes "r", "w" and "a" is supported.

More protocols like FTP, SCP and Amazon S3 would be useful.

Known issues
------------
Misspelled password stored on the OSX Keychain, have to be deleted manually with the Keychain Access application.

Credits
-------

  * Tanaka Akira for the inspirational ['open-uri'](https://github.com/ruby/ruby/blob/trunk/lib/open-uri.rb) standard ruby library.
  * Miron Cuperman for the ['net/dav'](https://github.com/devrandom/net_dav) gem used to access webdav servers.
  * Chris Roberts and the rest of the DAV4Rack for the WebDAV implementation in ruby used for testing this gem.

License
-------
OpenUriAndWrite is distributed under the Apache License, Version 2.0.

Author
------

Thomas Flemming

  * [@thomasfl](https://twitter.com/#!/thomasfl)
  * [http://github.com/thomasfl/](http://github.com/thomasfl/)
