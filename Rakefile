require "bundler/gem_tasks"

task :test do
  sh "rgot -v #{Dir.glob("lib/**/*_test.rb").join(' ')}"
end

task :default => [:test]
