require 'pony'

class EventNotifier
  def self.send_notifications(upcoming_events)
    if !upcoming_events.happening_tomorrow.empty?
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

