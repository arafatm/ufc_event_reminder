require 'redis'

class Store

  ### Class Methods

  def self.initialize_with_events(events)
    store = new(initialize_redis)
    store.save_events(events)

    store
  end

  def self.initialize_redis
    if ENV["REDISCLOUD_URL"]
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    else
      Redis.new
    end
  end

  ### Instance Methods

  def initialize(redis = Store.initialize_redis)
    @redis = redis
  end

  def save_events(events)
    if events
      @redis.set 'future_events', events.to_json
    end
  end

  def get_events
    EventCollection.initialize_from_json(@redis.get('future_events'))
  end
end
