require_relative File.join('..', '..', 'app')
require 'rspec'
require 'email_spec'

describe 'event_notifier.rb' do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:event) { Event.new('event 1', Date.parse('2020-01-20')) }

  it "sends an email with upcoming event information" do
    collection = EventCollection.new([event])
    collection.stub(:happening_tomorrow).and_return([event])

    EventNotifier.send_notifications(collection)
    deliveries.count.should == 1
    deliveries.first.body.include?('event 1').should be_true
  end
end
