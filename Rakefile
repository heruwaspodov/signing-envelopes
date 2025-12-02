# frozen_string_literal: true

require_relative 'config/application'

Rails.application.load_tasks

task :before_hook do
  @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  puts ">>>> start: #{@start_time}"
end

task :after_hook do
  at_exit do
    end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = end_time - @start_time

    puts ">>>> finish: #{end_time}"
    puts ">>>> elapsed: #{elapsed}"
  end
end

tasks = Rake.application.tasks

tasks.each do |task|
  next if [Rake::Task['before_hook'],
           Rake::Task['after_hook']].include?(task)

  task.enhance(%i[before_hook after_hook])
end
