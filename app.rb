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
    @name = self.get_name(html)
    @start_date = self.get_start_date(html)
    new(@name, @start_date)
  end

  def self.get_name(html)
    html.css('span[itemprop="name"]').first.children.first.text
  end

  def self.get_start_date(html)
    Date.parse(html.css('meta[itemprop="startDate"]').first.attributes['content'])
  end

  def to_hash
    {}.tap { |h| h['name'] = @name; h['start_date'] = @start_date }
  end

  def upcoming?
    start_date >= tomorrow
  end

  def happening_tomorrow?
    start_date <= tomorrow && start_date >= today
  end

  private
  def tomorrow
    today.next_day
  end

  def today
    DateTime.now.to_date
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
    select { |e| e.happening_tomorrow?  }
  end

  def upcoming
    select { |e| e.upcoming?  }
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
    @events = find_all_events.upcoming
  end

  def store
    redis = AppRedis.create
    if @events
      redis.set 'future_events', @events.to_json
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
        :body => erb(:'emails/notification'),
        :via => :smtp,
        :via_options => {
          :address => 'smtp.sendgrid.net',
          :port => '587',
          :domain => 'heroku.com',
          :user_name => ENV['SENDGRID_USERNAME'],
          :password => ENV['SENDGRID_PASSWORD'],
          :authentication => :plain,
          :enable_starttls_auto => true
        }
    end
  end
end

class AppRedis
  def self.create
    if ENV["REDISCLOUD_URL"]
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    else
      Redis.new
    end
  end
end
