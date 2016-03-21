require_dependency 'environment'

class Environment
  has_many :notifications, class_name: 'NotificationPlugin::Notification', :as => :target
end
