class FormBuilder < ActionView::Helpers::FormBuilder
  def name_for(method, options={})
    InstanceTag.new(object_name, method, self, object).name_for(options)
  end
end

class InstanceTag < ActionView::Helpers::InstanceTag
  def name_for(options)
    add_default_name_and_id(options)
    options['name']
  end
end

ActionView::Base.default_form_builder = FormBuilder