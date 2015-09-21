module Customizable

  def self.included(base)
    base.attr_accessible :custom_values
    base.extend ClassMethods
  end

  module ClassMethods
    def acts_as_customizable(options = {})
      has_many :custom_field_values, :dependent => :delete_all, :as => :customized
      send :include, Customizable::InstanceMethods
      after_save :save_custom_values
      validate :valid_custom_values?
    end

    def active_custom_fields
      CustomField.all.select{|cf| customized_ancestors_list.include?(cf.customized_type) && cf.active}
    end

    def required_custom_fields
      CustomField.all.select{|cf| customized_ancestors_list.include?(cf.customized_type) && cf.required}
    end

    def signup_custom_fields
      CustomField.all.select{|cf| customized_ancestors_list.include?(cf.customized_type) && cf.signup}
    end

    def custom_fields
      CustomField.all.select{|cf| customized_ancestors_list.include?(cf.customized_type)}
    end

    def customized_ancestors_list
      current=self
      result=[]
      while current.instance_methods.include? :custom_value do
        result << current.name
        current=current.superclass
      end
      result
    end

  end

  class ValueWrapper
    attr_accessor :value, :customized, :custom_field, :public
  end

  module InstanceMethods

    def valid_custom_values?
      is_valid = true
      return is_valid if @custom_values.blank?
      @custom_values.each do |cv|
        if cv.value.blank? && cv.custom_field.required
          errors.add(cv.custom_field.name,"can't be blank")
          is_valid=false
        end
      end
      success
    end

    def customized_class
      current=self.class
      while current.instance_methods.include? :custom_fields do
        result=current
        current=current.superclass
      end
      result.name
    end

    def custom_values=(values)
      values = values.stringify_keys
      @custom_values=nil
      @custom_values=custom_values
      @custom_values.each do |custom_value|
        key = custom_value.custom_field.name
        unless !values.has_key?(key)
          if values[key].is_a?(Hash)
            custom_value.value = values[key]['value'].to_s
            custom_value.public = values[key].has_key?('public') ? values[key]['public']=="true" : false
          else
            custom_value.value = values[key].to_s
            custom_value.public = false
          end
        end
      end
    end

    def custom_values
      if @custom_values.blank?
        @custom_values=[]
        self.class.custom_fields.each do |field|
          v = ValueWrapper.new
          v.customized=self
          v.custom_field = field
          v.public = is_public(field.name)
          v.value = custom_value(field.name)
          @custom_values << v
        end
      end
      @custom_values
    end

    def is_public(field_name)
      cv = @custom_values.detect{|value| value.custom_field.name == field_name} unless @custom_values.blank?
      cv ||= CustomFieldValue.all.detect {|cv| belongs_to_self(cv) && cv.custom_field.name == field_name}
      cv.nil? ? false : cv.public
    end

    def public_values
      cv = @custom_values.select{|value| value.public} unless @custom_values.blank?
      cv ||= CustomFieldValue.all.select {|cv| belongs_to_self(cv) && cv.public}
      cv
    end

    def custom_value(field_name)
      cv = @custom_values.detect{|value| value.custom_field.name == field_name} unless @custom_values.blank?
      cv ||= CustomFieldValue.all.detect {|cv| belongs_to_self(cv) && cv.custom_field.name == field_name}
      cv.nil? ? default_value_for(field_name) : cv.value
    end

    def belongs_to_self(value)
      inherited_or_self_type = self.class.customized_ancestors_list.include?(value.customized_type)
      correct_id = value.customized_id == self.id
      inherited_or_self_type && correct_id
    end

    def default_value_for(field_name)
      field=self.class.custom_fields.detect {|c| c.name == field_name}
      field.nil? ? nil : field.default_value
    end

    def save_custom_values
      return false if @custom_values.blank?
      custom_values_to_save = []
      @custom_values.each do |custom_value|
        value = CustomFieldValue.all.detect {|cv| belongs_to_self(cv) && cv.custom_field.name == custom_value.custom_field.name}
        if value.nil?
          value = CustomFieldValue.new
          value.custom_field = custom_value.custom_field
          value.customized = self
        end

        value.public = custom_value.public
        value.value = custom_value.value
        custom_values_to_save << value
      end
      custom_field_values = custom_values_to_save
      custom_field_values.each(&:save)
      true
    end

    def reset_custom_values!
      @custom_values = nil
    end

  end
end

ActiveRecord::Base.send(:include, Customizable)
