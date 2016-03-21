require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'
require(
  File.expand_path(File.dirname(__FILE__)) +
  '/../../controllers/notification_plugin_myprofile_controller'
)

class NotificationPluginMyprofileControllerTest < ActionController::TestCase
  def setup
    @controller = NotificationPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('person').person
    @community = fast_create(Community)

    environment = Environment.default
    environment.enable_plugin('NotificationPlugin')
    environment.save!

    login_as(@person.user.login)
    NotificationPluginMyprofileController.any_instance.stubs(:profile).returns(@community)
  end

  attr_accessor :person

  should 'profile admin be able to create a notification' do
    @community.add_admin(@person)
    post :new, :profile => @community.identifier,
                :notifications => {
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

  should 'a regular user not to be able to create a notification' do
    post :new, :profile => @community.identifier,
    :notifications => {
      :message => "Message",
      :active => true,
      :type => "NotificationPlugin::DangerNotification"
    }

  assert_redirected_to :root
  assert_nil NotificationPlugin::Notification.last
  end

  should 'profile admin be able to edit a notification' do
    @community.add_admin(@person)
    @notification = NotificationPlugin::Notification.create(
      :target => @community,
      :message => "Message",
      :active => true,
      :type => "NotificationPlugin::DangerNotification"
    )

    post :edit, :profile => @community.identifier, :id => @notification.id,
    :notifications => {
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

  should 'a regular user not be able to edit a notification' do
    @notification = NotificationPlugin::Notification.create(
      :target => @community,
      :message => "Message",
      :active => true,
      :type => "NotificationPlugin::DangerNotification"
    )
    post :edit, :profile => @community.identifier,
    :notifications => {
      :message => "Edited Message",
      :active => false,
      :type => "NotificationPlugin::DangerNotification"
    }
    @notification.reload
    assert_redirected_to :root
    assert_equal "Message", @notification.message
    assert @notification.active
  end

  should 'a profile admin be able to destroy a notification' do
    @community.add_admin(@person)
    @notification = NotificationPlugin::Notification.create(
                      :target => @community,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
    delete :destroy, :profile => @community.identifier, :id => @notification.id
    assert_nil NotificationPlugin::Notification.find_by_id(@notification.id)
  end

  should 'a regular user not be able to destroy a notification' do
    @notification = NotificationPlugin::Notification.create(
                      :target => @community,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
    delete :destroy, :profile => @community.identifier, :id => @notification.id

    assert_redirected_to :root
    assert_not_nil NotificationPlugin::Notification.find_by_id(@notification.id)
  end

  should 'a profile admin be able to change Notification status' do
    @community.add_admin(@person)
    @notification = NotificationPlugin::Notification.create(
                      :target => @community,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
    post :change_status, :profile => @community.identifier, :id => @notification.id
    assert_redirected_to :action => 'index'

    @notification.reload
    assert !@notification.active
  end

  should 'a regular user not be able to change Notification status' do
    @notification = NotificationPlugin::Notification.create(
                      :target => @community,
                      :message => "Message",
                      :active => true,
                      :type => "NotificationPlugin::DangerNotification"
                    )
    post :change_status, :profile => @community.identifier, :id => @notification.id
    assert_redirected_to :root

    @notification.reload
    assert @notification.active
  end

end
