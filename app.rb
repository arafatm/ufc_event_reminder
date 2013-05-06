require 'nokogiri'
require 'open-uri'
require 'json'
require 'redis'
require 'pony'

class Event
  attr_reader :name, :start_date

  def initialize(name, start_date)
    @name = name
    @start_date = start_date
  end

  def self.initialize_from_html(html)
    @html = html
    @name = get_name
    @start_date = get_start_date
  end

  def get_name
    @html.css('span[itemprop="name"]').first.children.first.text
  end

  def get_start_date
    Date.parse(@html.css('meta[itemprop="startDate"]').first.attributes['content'])
  end

  def to_hash
    {}.tap { |h| h['name'] = @name; h['start_date'] = @start_date }
  end
end

class EventCollection
  attr_reader :collection

  def initialize(arr)
    @collection = arr.sort{ |a, b| a.start_date <=> b.start_date }
  end

  def self.initialize_from_html(html)
    arr = []
    html.each do |tr|
      arr << Event.initialize_from_html(tr)
    end

    new(arr)
  end

  def self.initialize_from_json(json)
    arr = []
    JSON.parse(json).each do |h|
      arr << Event.new(h['name'], Date.parse(h['start_date']))
    end

    new(arr)
  end

  def happening_tomorrow
    select { |e| e.start_date <= tomorrow  }
  end

  def tomorrow
    DateTime.now.to_date.next_day
  end

  def next_event
    @collection.first
  end

  def to_json
    h_arr = []
    @collection.each do |event|
      h_arr << event.to_hash
    end

    h_arr.to_json
  end

  def select(&block)
    self.class.new(@collection.select(&block))
  end

  def count
    @collection.count
  end

  def empty?
    @collection.empty?
  end
end

class EventFinder
  URL = "http://www.sherdog.com/organizations/Ultimate-Fighting-Championship-2"

  attr_reader :events

  def initialize
    @page = Nokogiri::HTML(open(URL))
    @events = find_future_events
  end

  def store
    redis = Redis.new
    if @events
      redis.set 'future_events', @events.to_json
    end
  end

  def find_future_events
    find_all_events.select do |e|
      e.start_date >= DateTime.now
    end
  end

  def find_all_events
    event_html = @page.css('tr[itemtype="http://schema.org/Event"]')
    EventCollection.initialize_from_html(event_html)
  end
end

class EventNotifier
  def initialize(event_finder)
    @finder = event_finder || EventFinder.new
  end

  def send_notifications
    if !@finder.events.happening_tomorrow.empty?
      Pony.mail :to => 'sachin@ranchod.co.za',
        :from => 'sachin@ranchod.co.za',
        :subject => 'UFC event reminder',
        :body => erb(:'emails/notification')
    end
  end
end
