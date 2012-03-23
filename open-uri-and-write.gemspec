# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "open-uri-and-write/version"

Gem::Specification.new do |s|
  s.name        = "open-uri-and-write"
  s.version     = OpenUriAndWrite::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Flemming"]
  s.email       = ["thomas.flemming@gmail.com"]
  s.homepage    = "https://github.com/thomasfl/open-uri-and-write"
  s.summary     = %q{An easy to use wrapper for Net::Dav, for writing files to WebDAV enabled web servers.}
  s.description = %q{Use normal file operations to write files to WebDAV enabled web servers.}

  s.add_runtime_dependency "highline", "~>1.6.9"
  s.add_runtime_dependency "net_dav", "~>0.5.0"
  s.add_development_dependency "rspec", "~>2.5.0"
  s.add_development_dependency "pry", "~>0.9.8.4"
  s.add_development_dependency "dav4rack", "~>0.2.10" 

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
