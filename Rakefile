require 'rspec/core/rake_task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "solve360"
    gem.summary = "Libary for working with the Solve360 CRM API"
    gem.email = "Stephen Bartholomew"
    gem.homepage = "http://github.com/curve21/solve360"
    gem.description = ""
    gem.authors = ["Stephen Bartholomew"]
    gem.files =  FileList["[A-Z]*", "{lib,spec}/**/*"]
    gem.add_dependency("configify", ">=0.0.1")
    gem.add_dependency("activesupport")  
    gem.add_dependency("httparty", ">=0.4.5")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--options', 'spec/spec.opts']
end

RSpec::Core::RakeTask.new(:coverage) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = ['--exclude', 'examples']
end

begin
  require "yard"
  YARD::Rake::YardocTask.new do |t|
    t.files   = ["lib/**/*.rb"]
  end
rescue LoadError
  puts "You'll need yard to generate documentation: gem install yard"
end