require_relative "../test_helper"

class ActsAsCustomizableTest < ActiveSupport::TestCase

  should 'save custom field values for person' do
    person = create_user('testinguser').person
    CustomField.create!(:name => "Blog", :format => "string", :customized_type => "Person", :active => true)
    assert_difference 'CustomFieldValue.count' do
      person.custom_values = { "Blog" => { "value" => "www.blog.org", "public" => "0"} }
      person.save!
      assert_equal 'www.blog.org', CustomFieldValue.find(:last, :conditions => {:customized_id => person.id}).value
    end
  end

end
