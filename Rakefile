require 'rubygems'
require 'rake'

require 'spec/rake/spectask'
exit

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

desc "release with no version change"
task :dist => [:clean, :release]

namespace :dist do
  desc "release patch"
  task :patch => [:clean, "version:bump:patch", :release]
  desc "release with minor version bump"
  task :minor => [:clean, "version:bump:minor", :release]
end

desc "build gem into pkg directory"
task :gem => [:build]

task :clean do
  Dir.glob("**/*~").each do |file|
    File.unlink file
  end
  puts "cleaned"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "net_dav #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
