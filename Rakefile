# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

require "rake/testtask"

# Fix for Rails engine db:test:prepare task
namespace :app do
  namespace :db do
    namespace :test do
      task :prepare do
        # Delegate to the dummy app's db:test:prepare task
        Rake::Task["db:test:prepare"].invoke
      end
    end
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = [
    "test/components/flat_pack/*_test.rb",
    "test/lib/flat_pack/*_test.rb"
  ]
  t.verbose = false
end

task default: :test
