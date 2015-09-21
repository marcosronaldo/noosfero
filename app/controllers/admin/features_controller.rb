class FeaturesController < AdminController
  protect 'edit_environment_features', :environment
  helper CustomFieldsHelper

  def index
    @features = Environment.available_features.sort_by{|k,v|v}
  end

  post_only :update
  def update
    if @environment.update_attributes(params[:environment])
      session[:notice] = _('Features updated successfully.')
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end

  def manage_fields
    @person_fields = Person.fields
    @person_custom_fields = Person.custom_fields
    @enterprise_fields = Enterprise.fields
    @enterprise_custom_fields = Enterprise.custom_fields
    @community_fields = Community.fields
    @community_custom_fields = Community.custom_fields
  end

  def manage_person_fields
    environment.custom_person_fields = params[:person_fields]
    if environment.save!
      session[:notice] = _('Person fields updated successfully.')
    else
      flash[:error] = _('Person fields not updated successfully.')
    end
    redirect_to :action => 'manage_fields'
  end

  def manage_enterprise_fields
    environment.custom_enterprise_fields = params[:enterprise_fields]
    if environment.save!
      session[:notice] = _('Enterprise fields updated successfully.')
    else
      flash[:error] = _('Enterprise fields not updated successfully.')
    end
    redirect_to :action => 'manage_fields'
  end

  def manage_community_fields
    environment.custom_community_fields = params[:community_fields]
    if environment.save!
      session[:notice] = _('Community fields updated successfully.')
    else
      flash[:error] = _('Community fields not updated successfully.')
    end
    redirect_to :action => 'manage_fields'
  end

  def manage_custom_fields
    custom_field_list = params[:custom_fields] || {}

    params[:customized_type].constantize.custom_fields.each do |cf|
      cf.destroy if !custom_field_list.collect{|k,v|k}.include? cf.id
    end

    custom_field_list.each_pair do |id, custom_field|
      field = CustomField.find_by_id(id)
      if not field.blank?
        params_to_update = custom_field.except(:format, :extras, :customized_type)
        field.update_attributes(params_to_update)
      else
        if !custom_field[:extras].nil?
          tmp = []
          custom_field[:extras].each_pair do |k, v|
            tmp << v
          end
          custom_field[:extras] = tmp
        end
        field =  CustomField.new custom_field
        field.save if field.valid?
      end
    end
    redirect_to :action => 'manage_fields'
  end

  def search_members
    arg = params[:q].downcase
    result = environment.people.find(:all, :conditions => ['LOWER(name) LIKE ? OR identifier LIKE ?', "%#{arg}%", "%#{arg}%"])
    render :text => prepare_to_token_input(result).to_json
  end

end
