class OrganizationMailing < Mailing

  settings_items :name, :type => String
  settings_items :roles, :type => Array

  def generate_from
    "#{person.name} <#{source.environment.noreply_email}>"
  end

  def recipients(offset=0, limit=100)

    result = source.members.order(:id)
                 .joins("LEFT OUTER JOIN mailing_sents m ON (m.mailing_id = #{id} AND m.person_id = profiles.id)")
                 .offset(offset).limit(limit)

    result = result.where('m.person_id IS ?', nil)

    if data.is_a?(Hash) and !data.empty?

      result = result.where('LOWER(name) LIKE ?', '%'+data[:name].downcase+'%') if data[:name]

      result = result.where('role_assignments.role_id' => data[:roles]) if data[:roles]

    end

    result
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
