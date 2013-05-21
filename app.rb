require 'sinatra'
require 'json'

Dir[File.join(File.dirname(__FILE__), 'app', '*.rb')].each do |file|
  require file
end

class App

  def self.upcoming_events
    events = get_events_from_store
    events.upcoming
  end

  private
  def self.get_events_from_store
    @store ||= Store.initialize_with_events(EventFinder.new.events)
    @store.get_events
  end
end
