# frozen_string_literal: true

require 'rake/testtask'
require 'cucumber/rake/task'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = ['features']
end
