# Encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'spree/testing_support/common_rake'

RSpec::Core::RakeTask.new

task :default => :spec

spec = eval(File.read('spree_api_exchange.gemspec'))

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
end

desc "Release to gemcutter"
task :release do
  version = File.read(File.expand_path("../../SPREE_VERSION", __FILE__)).strip
  cmd = "cd pkg && gem push spree-api-exchange_-#{version}.gem"; puts cmd; system cmd
end

desc "Generates a dummy app for testing"
task :test_app do
  ENV['LIB_NAME'] = 'spree_api_exchange'
  Rake::Task['common:test_app'].invoke
end