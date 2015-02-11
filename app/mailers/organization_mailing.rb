class OrganizationMailing < Mailing

  settings_items :name, :type => String
  settings_items :roles, :type => Array

  def generate_from
    "#{person.name} <#{source.environment.noreply_email}>"
  end

  #@todo Modify this consult with stored data filter
  def recipients(offset=0, limit=100)
    conditions = {
      :key =>'m.person_id IS :person_id',
      :value => {:person_id => nil}
    }

    if data.is_a?(Hash) and !data.blank?
      if data[:name]
        conditions[:key] += ' AND LOWER(name) LIKE :name'
        conditions[:value][:name] = "%#{data[:name].downcase}%"

      end

      if data[:roles]
        conditions[:key] += ' AND role_assignments.role_id IN (:roles)'
        conditions[:value][:roles] = data[:roles].join(',')
      end

    end

    source.members.all(:order => :id, :offset => offset, :limit => limit, :joins => "LEFT OUTER JOIN mailing_sents m ON (m.mailing_id = #{id} AND m.person_id = profiles.id)", :conditions => [conditions[:key],conditions[:value]])
  end

  def each_recipient
    offset = 0
    limit = 50
    while !(people = recipients(offset, limit)).empty?
      people.each do |person|
        yield person
      end
      offset = offset + limit
    end
  end

  def signature_message
    _('Sent by community %s.') % source.name
  end

  include Rails.application.routes.url_helpers
  def url
    url_for(source.url)
  end
end
