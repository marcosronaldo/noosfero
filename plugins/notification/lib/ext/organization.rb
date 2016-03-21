require_dependency 'organization'

class Organization
  has_many :notifications, class_name: 'NotificationPlugin::Notification', :as => :target
end
