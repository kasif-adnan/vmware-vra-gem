# frozen_string_literal: true
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "chefstyle"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:test)
RuboCop::RakeTask.new do |task|
  task.options << "--display-cop-names"
end

task default: %i{test rubocop}
