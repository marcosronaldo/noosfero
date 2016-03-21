require_dependency 'user'

class User
  has_many :notifications_users, :class_name => 'NotificationPlugin::NotificationsUser'
  has_many :notifications, :through => :notifications_users
end
