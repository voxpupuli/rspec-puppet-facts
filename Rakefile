# frozen_string_literal: true

PUPPET_VERSIONS_PATH = File.join(__dir__, 'ext', 'puppet_agent_facter_versions.json')

begin
  require 'rspec/core/rake_task'
  require 'yard'
  RSpec::Core::RakeTask.new(:spec)
  YARD::Rake::YardocTask.new
rescue LoadError
  # yard is optional
end

desc 'Produce Commit history since last tag'
task :dump_commit do
  last_tag = `git describe --tags $(git rev-list --tags --max-count=1)`.chomp
  puts "############ Commits since #{last_tag} ######"
  puts `git log --pretty=format:"- %s" #{last_tag}..HEAD`
end

namespace :puppet_versions do
  desc 'updates the vendored list of puppet versions & components'
  task :update do
    warn 'The rake task is disabled since the 6.0.0 Release. Please see the README.md'
    exit 1
  end

  desc 'runs all tests and verifies vendored component list'
  task :test do
    warn 'The rake task is disabled since the 6.0.0 Release. Please see the README.md'
    exit 1
  end
end

begin
  require 'github_changelog_generator/task'
rescue LoadError
  # github_changelog_generator is an optional group
else
  require 'rubygems'
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog github_actions]
    config.user = 'voxpupuli'
    config.project = 'rspec-puppet-facts'
    gem_version = Gem::Specification.load("#{config.project}.gemspec").version
    config.future_release = gem_version
  end

  # Workaround for https://github.com/github-changelog-generator/github-changelog-generator/issues/715
  require 'rbconfig'
  if RbConfig::CONFIG['host_os'].include?('linux')
    task :changelog do
      puts 'Fixing line endings...'
      changelog_file = File.join(__dir__, 'CHANGELOG.md')
      changelog_txt = File.read(changelog_file)
      new_contents = changelog_txt.gsub("\r\n", "\n")
      File.open(changelog_file, 'w') { |file| file.puts new_contents }
    end
  end
end

begin
  require 'voxpupuli/rubocop/rake'
rescue LoadError
  # the voxpupuli-rubocop gem is optional
end
