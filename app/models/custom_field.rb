class CustomField < ActiveRecord::Base
  attr_accessible :name, :default_value, :format, :extras, :customized_type, :active, :required, :signup
  serialize :customized_type
  serialize :extras
  has_many :custom_field_values, :dependent => :delete_all

  validates_presence_of :name, :format, :customized_type
  validates_uniqueness_of :name
  validate :related_to_other?

  def related_to_other?
    CustomField.all.any? do |cf|
      if cf.name == name && cf.customized_type != customized_type
        ancestor = cf.customized_type.constantize < customized_type.constantize
        descendant = cf.customized_type.constantize > customized_type.constantize
        if ancestor || descendant
          errors.add(:body, N_("New field related to existent one with same name"))
          return false
        end
      end
    end
    true
  end
end

