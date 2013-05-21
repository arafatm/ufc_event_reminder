require './app'

get '/' do
  @future_events = App.upcoming_events
  erb(:'pages/index')
end
