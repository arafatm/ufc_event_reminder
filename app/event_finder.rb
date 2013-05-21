require 'nokogiri'
require 'open-uri'

class EventFinder
  URL = "http://www.sherdog.com/organizations/Ultimate-Fighting-Championship-2"

  attr_reader :events

  def initialize
    @page = Nokogiri::HTML(open(URL))
    @events = find_all_events
  end

  def find_all_events
    event_html = @page.css('tr[itemtype="http://schema.org/Event"]')
    EventCollection.initialize_from_html(event_html)
  end
end
