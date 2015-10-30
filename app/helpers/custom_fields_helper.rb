module CustomFieldsHelper

  def format_name(format)
    names = {}
    names['string'] = _('String')
    names['text'] = _('Text')
    names['date'] = _('Date')
    names['numeric'] = _('Numeric')
    names['link'] = _('Link')
    names['list'] = _('List')
    names['checkbox'] = _('Checkbox')
    names[format]
  end

  def custom_field_forms(customized_type)
    forms = []
    forms << [_('String'), form_for_format(customized_type,'string')]
    forms << [_('Text'), form_for_format(customized_type,'text')]
    forms << [_('Date'), form_for_format(customized_type,'date')]
    forms << [_('Numeric'), form_for_format(customized_type,'numeric')]
    forms << [_('Link'), form_for_format(customized_type,'link')]
    forms << [_('List'), form_for_format(customized_type,'list')]
    forms << [_('Checkbox'), form_for_format(customized_type,'checkbox')]
    forms
  end

  def render_view_for_custom_field(field)
    "custom_fields/#{field.format}"
  end

  def render_extras_field(id, extra=nil, field=nil)
    if extra.nil?
      CGI::escapeHTML((render(:partial => 'features/custom_fields/extras_field', :locals => {:id => id, :extra => nil, :field => field})))
    else
      render :partial => 'features/custom_fields/extras_field', :locals => {:id => id, :extra => extra, :field => field}
    end
  end

  def form_for_field(field, customized_type)
    render :partial => 'features/custom_fields/form', :locals => {:field => field, :customized_type => customized_type}
  end

  private

  def form_for_format(customized_type, format)
    CGI::escapeHTML((render(:partial => 'features/custom_fields/form', :locals => {:customized_type => customized_type, :field => nil, :format => format})))
  end
end
