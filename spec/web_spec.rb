require_relative File.join('..', 'web')
require 'date'
require 'rspec'
require 'rack/test'

set :environment, :test

describe 'Web.rb' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "shows information on upcoming events" do
    App.stub(:upcoming_events).and_return(EventCollection.new([Event.new('event 1', Date.parse('2020-01-20'))]))
    get '/'
    last_response.should be_ok
    last_response.body.match('Tracking 1 upcoming UFC events').should be_true
    last_response.body.match('Next event: event 1 on 2020-01-20').should be_true
  end

  it "shows YES if UFC event is tomorrow" do
    tomorrow = Time.now.to_date.next_day
    App.stub(:upcoming_events).and_return(EventCollection.new([Event.new('event 1', tomorrow)]))
    get '/'
    last_response.should be_ok
    last_response.body.match('Tracking 1 upcoming UFC events').should be_true
    last_response.body.match('YES').should be_true
  end
end
