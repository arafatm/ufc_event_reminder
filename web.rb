require './app'
require 'sinatra'

get '/' do
  @redis ||= Redis.new
  unless @redis.get('future_events')
    ef = EventFinder.new
    ef.store
  end

  @redis.get('future_events')
end
