require './app'
require 'sinatra'

get '/' do
  @redis ||= AppRedis.create
  unless @redis.get('future_events')
    ef = EventFinder.new
    ef.store
  end

  stored_events = EventCollection.initialize_from_json(@redis.get('future_events'))
  @future_events = stored_events.upcoming
  erb(:'pages/index')
end
