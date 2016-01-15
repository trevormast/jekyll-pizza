require 'rake'
require 'bundler'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

task default: [:rubocop, :spec]

desc 'Run rubocop'
task :rubocop do
  RuboCop::RakeTask.new
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--format documentation'
  # t.rspec_opts << ' more options'
  # t.rcov = true
end
