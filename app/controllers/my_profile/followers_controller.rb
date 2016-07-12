class FollowersController < MyProfileController

  before_action :only_for_person, :only => :index
  before_action :accept_only_post, :only => [:update_category]

  def index
    @followed_people = current_person.followed_profiles.order(:type)
    @profile_types = {_('All profiles') => nil}.merge(Circle.profile_types).to_a

    if params['filter'].present?
      @followed_people = @followed_people.where(:type => params['filter'])
      @active_filter = params['filter']
    end

    @followed_people = @followed_people.paginate(:per_page => 15, :page => params[:npage])
  end

  def set_category_modal
    profile = Profile.find(params[:followed_profile_id])
    circles = Circle.where(:person => current_person, :profile_type => profile.class.name)
    render :partial => 'followers/edit_circles_modal', :locals => { :circles => circles, :profile => profile }
  end

  def update_category
    followed_profile = Profile.find_by(:id => params["followed_profile_id"])

    selected_circles = params[:circles].map{|circle_name, circle_id| Circle.find_by(:id => circle_id)}.select{|c|not c.nil?}

    if followed_profile
      current_person.update_profile_circles(followed_profile, selected_circles)
      render :text => _("Circles of %s updated successfully") % followed_profile.name, :status => 200
    else
      render :text => _("Error: No profile to follow."), :status => 400
    end
  end

  protected

  def only_for_person
    render_not_found unless profile.person?
  end

end
