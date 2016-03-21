require 'test_helper'
require_relative '../../controllers/notification_plugin_admin_controller'

class NotificationPluginAdminControllerTest < ActionController::TestCase
  def setup
    @controller = NotificationPluginAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('person').person

    @environment = Environment.default
    @environment.enable_plugin('NotificationPlugin')
    @environment.save!

    login_as(@person.user.login)
  end

  attr_accessor :person

  should 'an admin be able to create a notification' do
    @environment.add_admin(@person)
     post :new, :notifications => {
                  :message => "Message",
                  :active => true,
                  :type => "NotificationPlugin::DangerNotification"
                }
     assert_redirected_to :action => 'index'
     notification = NotificationPlugin::Notification.last
     assert_equal "Message", notification.message
     assert notification.active
     assert_equal "NotificationPlugin::DangerNotification", notification.type
  end

  should 'an user not to be able to create a notification' do
     post :new, :notifications => {
                  :message => "Message",
                  :active => true,
                  :type => "NotificationPlugin::DangerNotification"
                }
     assert_redirected_to :root
     assert_nil NotificationPlugin::Notification.last
  end

   should 'an admin be able to edit a notification' do
    @environment.add_admin(@person)
    @notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
     post :edit, :id => @notification.id, :notifications => {
                                            :message => "Edited Message",
                                            :active => false,
                                            :type => "NotificationPlugin::WarningNotification"
                                          }
     @notification = NotificationPlugin::Notification.last
     assert_redirected_to :action => 'index'
     assert_equal "Edited Message", @notification.message
     assert !@notification.active
     assert_equal "NotificationPlugin::WarningNotification", @notification.type
  end

  should 'an user not to be able to edit a notification' do
    @notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
     post :edit, :notifications => {
                   :message => "Edited Message",
                   :active => false,
                   :type => "NotificationPlugin::DangerNotification"
                 }
     @notification.reload
     assert_redirected_to :root
     assert_equal "Message", @notification.message
     assert @notification.active
  end

  should 'an admin be able to destroy a notification' do
    @environment.add_admin(@person)
    @notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
    delete :destroy, :id => @notification.id
    assert_nil NotificationPlugin::Notification.find_by id: @notification.id
  end

  should 'an user not to be able to destroy a notification' do
    @notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
     delete :destroy, :id => @notification.id

     assert_redirected_to :root
     assert_not_nil NotificationPlugin::Notification.find_by id: @notification.id
  end

  should 'an admin be able to change Notification status' do
    @environment.add_admin(@person)
    @notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
     post :change_status, :id => @notification.id
     assert_redirected_to :action => 'index'

     @notification.reload
     assert !@notification.active
  end

  should 'an user not be able to change Notification status' do
    @notification = NotificationPlugin::Notification.create(
                      :target => @environment,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
     post :change_status, :id => @notification.id
     assert_redirected_to :root

     @notification.reload
     assert @notification.active
  end

end
