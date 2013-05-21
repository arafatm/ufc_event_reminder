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

