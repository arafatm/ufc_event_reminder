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

