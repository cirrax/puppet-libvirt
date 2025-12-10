begin
  require 'voxpupuli/test/rake'
rescue LoadError
  begin
    require 'puppetlabs_spec_helper/rake_tasks'
  rescue LoadError
  end
end

require 'puppet_blacksmith/rake_tasks'

desc 'run autocorrection tasks'
task :fix do
  puts "--------\nrunning: rake lint_fix"
  Rake::Task["lint_fix"].invoke
  puts "--------\nrunning: rake rubocop:autocorrect"
  Rake::Task["rubocop:autocorrect"].invoke
end

Rake::Task["test"].clear
desc 'run several tests in one run'
task :test do
  puts "--------\nrunning: rake validate"
  Rake::Task["validate"].invoke
  puts "--------\nrunning: rake check"
  Rake::Task["check"].invoke
  puts "--------\nrunning: rake lint"
  Rake::Task["lint"].invoke
  puts "--------\nrunning: yamllint"
  fail unless system('yamllint .')
  puts "--------\nrunning: rake rubocop"
  Rake::Task["rubocop"].invoke
  puts "--------\nrunning: rake strings:validate:reference"
  Rake::Task["strings:validate:reference"].invoke
end

# flag out some things we never use
Rake::Task["strings:gh_pages:update"].clear

# vim: syntax=ruby
