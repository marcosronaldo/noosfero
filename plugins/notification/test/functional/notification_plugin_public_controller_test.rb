require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'
require(
  File.expand_path(File.dirname(__FILE__)) +
  '/../../controllers/public/notification_plugin_public_controller'
)

class NotificationPluginPublicControllerTest < ActionController::TestCase
  def setup
    @controller = NotificationPluginPublicController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('person').person

    @environment = Environment.default
    @environment.enable_plugin('NotificationPlugin')
    @environment.save!

    login_as(@person.user.login)
  end

  should 'a logged in user be able to permanently hide notifications' do
    @notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
     post :close_notification, :notification_id => @notification.id
     assert_equal "true", @response.body
     assert @notification.users.include?(@person.user)
  end

  should 'a logged in user be able to momentarily hide notifications' do
    @notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )

    @another_notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Another Message",
                      :active => true,
                      :type => "NotificationPlugin::WarningNotification"
                    )
     post :hide_notification, :notification_id => @notification.id
     assert_equal "true", @response.body
     assert @controller.hide_notifications.include?(@notification.id)
     assert !@controller.hide_notifications.include?(@another_notification.id)
  end

  should 'not momentarily hide any notification if its id is not found' do
    @notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )

     post :hide_notification, :notification_id => nil
     assert_equal "false", @response.body
     assert !@controller.hide_notifications.include?(@notification.id)
  end
end
