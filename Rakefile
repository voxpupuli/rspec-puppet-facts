require 'bundler/gem_tasks'

begin
    require 'rspec/core/rake_task'
    require 'yard'
    RSpec::Core::RakeTask.new(:spec)
    YARD::Rake::YardocTask.new
rescue LoadError
end

desc 'Produce Commit history since last tag'
task :dump_commit do
  last_tag = `git describe --tags $(git rev-list --tags --max-count=1)`.chomp
  puts "############ Commits since #{last_tag} ######"
  puts `git log --pretty=format:"- %s" #{last_tag}..HEAD`
end
