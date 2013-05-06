require './app'
require 'sinatra'

get '/' do
  @redis ||= Redis.new
  unless @redis.get('future_events')
    ef = EventFinder.new
    ef.store
  end

  @future_events = EventCollection.initialize_from_json(@redis.get('future_events'))
  erb(:'pages/index')
end
