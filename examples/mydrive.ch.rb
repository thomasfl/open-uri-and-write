require 'rubygems'
require 'open-uri-and-write'

# Sign up for a free webdav account at mydrive.ch first. The script
# will prompt for username and password.

file = open("https://webdav.mydrive.ch/my_file.txt","w")
file.puts("Some content!")
file.close
