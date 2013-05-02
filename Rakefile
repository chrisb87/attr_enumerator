require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "attr_enumerator"
  gem.homepage = "http://github.com/chrisb87/attr_enumerator"
  gem.license = "MIT"
  gem.summary = %Q{A method for restricting an attribute to a set of choices}
  gem.description = %Q{A method for restricting an attribute to a set of choices}
  gem.email = "baker.chris.3@gmail.com"
  gem.authors = ["Chris Baker"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec
