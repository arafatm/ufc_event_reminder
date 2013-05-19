require './app'
require 'sinatra'

task :refresh_and_send_notifications do
  puts "Fetching UFC fights"
  ef = EventFinder.new
  puts "#{ef.events.count} upcoming fights"
  ef.store

  notifier = EventNotifier.new(ef)
  notifier.send_notifications
end
