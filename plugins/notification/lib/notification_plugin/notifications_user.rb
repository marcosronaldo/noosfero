class NotificationPlugin::NotificationsUser < ActiveRecord::Base
  self.table_name = "notification_plugin_notifications_users"

  belongs_to :user
  belongs_to :notification, class_name: 'NotificationPlugin::Notification'

  attr_accessible :user_id, :notification_id

  validates_uniqueness_of :user_id, :scope => :notification_id
end
