require './app'

task :refresh_and_send_notifications do
  puts "Fetching UFC fights"
  upcoming = EventFinder.new.events.upcoming
  puts "#{upcoming.count} upcoming fights"
  Store.new.save_events(upcoming)
  puts "saving events"
  puts "sending any notifications"
  EventNotifier.send_notifications(upcoming)
end
