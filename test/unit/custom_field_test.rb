require_relative "../test_helper"

class CustomFieldTest < ActiveSupport::TestCase

  def setup
    @person = create_user('test_user').person
    @community = create(Community, :environment => Environment.default, :name => 'my new community')

    @community_custom_field = CustomField.create(:name => "community_field", :format=>"myFormat", :default_value => "value for community", :customized_type=>"Community", :active => true)
    @person_custom_field = CustomField.create(:name => "person_field", :format=>"myFormat", :default_value => "value for person", :customized_type=>"Person", :active => true)
    @profile_custom_field = CustomField.create(:name => "profile_field", :format=>"myFormat", :default_value => "value for any profile", :customized_type=>"Profile", :active => true)
  end

  should 'create custom field' do
    assert CustomField.all.any?{|cf| cf.name == @community_custom_field.name}
    assert CustomField.all.any?{|cf| cf.name == @person_custom_field.name}
    assert CustomField.all.any?{|cf| cf.name == @profile_custom_field.name}

    assert Person.custom_fields.any?{|cf| cf.name == @person_custom_field.name}
  end

  should 'no access to custom field on sibling' do
    assert !(Person.custom_fields.any?{|cf| cf.name == @community_custom_field.name})
    assert !(Community.custom_fields.any?{|cf| cf.name == @person_custom_field.name})
  end

  should 'inheritance of custom_field' do
    assert Community.custom_fields.any?{|cf| cf.name == @profile_custom_field.name}
    assert Person.custom_fields.any?{|cf| cf.name == @profile_custom_field.name}
  end

  should 'save custom_field_values' do
    @community.custom_values = {"community_field" => "new_value!", "profile_field"=> "another_value!"}
    @community.save

    assert CustomFieldValue.all.any?{|cv| cv.custom_field_id == @community_custom_field.id && cv.customized_id == @community.id && cv.value == "new_value!"}
    assert CustomFieldValue.all.any?{|cv| cv.custom_field_id == @profile_custom_field.id && cv.customized_id == @community.id && cv.value = "another_value!"}
  end

  should 'delete custom field and its values' do
    @community.custom_values = {"community_field" => "new_value!", "profile_field"=> "another_value!"}
    @community.save

    old_id = @community_custom_field.id
    @community_custom_field.destroy

    assert !(CustomField.all.any?{|cf| cf.id == old_id})
    assert !(Community.custom_fields.any?{|cf| cf.name == "community_field"})
    assert !(CustomFieldValue.all.any?{|cv| cv.custom_field_id == old_id})
  end

  should 'not save related custom field' do
    another_field = CustomField.create(:name => "profile_field", :format=>"myFormat", :default_value => "value for any profile", :customized_type=>"Community")
    assert another_field.id.nil?
  end

  should 'not return inactive fields' do
    @community_custom_field.active=false
    @community_custom_field.save!

    assert !Community.active_custom_fields.any?{|cf| cf.name == @community_custom_field.name}
  end

  should 'delete a model and its custom field values' do
    @community.custom_values = {"community_field" => "new_value!", "profile_field"=> "another_value!"}
    @community.save

    old_id = @community.id
    @community.destroy
    assert !(Community.all.any?{|c| c.id == old_id})
    assert !(CustomFieldValue.all.any?{|cv| cv.customized_id == old_id && cv.customized_type == "Community"})
  end

  should 'keep field value if the field is reactivated' do

    @community.custom_values = {"community_field" => "new_value!"}
    @community.save

    @community_custom_field.active=false
    @community_custom_field.save!
    assert !Community.active_custom_fields.any?{|cf| cf.name == @community_custom_field.name}

    @community_custom_field.active=true
    @community_custom_field.save!
    @community.reload

    assert Community.active_custom_fields.any?{|cf| cf.name == @community_custom_field.name}
    assert_equal @community.custom_value("community_field"), "new_value!"
  end

  should 'list of required fields' do
    assert !Community.required_custom_fields.any?{|cf| cf.name == @community_custom_field.name}

    @community_custom_field.required=true
    @community_custom_field.save!
    @community.reload

    assert Community.required_custom_fields.any?{|cf| cf.name == @community_custom_field.name}
  end

  should 'list of signup fields' do
    assert !Community.signup_custom_fields.any?{|cf| cf.name == @community_custom_field.name}

    @community_custom_field.signup=true
    @community_custom_field.save!
    @community.reload

    assert Community.signup_custom_fields.any?{|cf| cf.name == @community_custom_field.name}
  end

  should 'public values handling' do
    assert !@community.is_public("community_field")
    @community.custom_values = {"community_field" => {"value" => "new_value!", "public"=>"true"}, "profile_field"=> "another_value!"}
    @community.save

    assert @community.is_public("community_field")
    assert !@community.is_public("profile_field")
  end

  should 'complete list of fields' do
    assert Person.custom_fields.include? @profile_custom_field
    assert Person.custom_fields.include? @person_custom_field
  end

  should 'get correct customized ancestors list' do
    puts Person.customized_ancestors_list
    assert (Person.customized_ancestors_list-["Person","Profile"]).blank?
  end
end

