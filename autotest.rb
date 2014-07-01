require 'rubygems'
require 'filewatcher'
require 'paint'

def run_tests
  puts Paint['Testing', :yellow]
  output = %x[ruby test/test-open-uri-and-write.rb]
  if(output[/Failure:/])
    puts output
    puts Paint['Failed to detect changes', :yellow, :bright]
  else
    puts output
    puts Paint['Ok', :green, :bright]
  end
end

run_tests
files = ["lib/open-uri-and-write.rb", "test/test-open-uri-and-write.rb"]
FileWatcher.new(files).watch(0.5) do |filename|
  run_tests
end
