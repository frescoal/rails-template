class DatepickerInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, { class: 'form-control datetime-local', autocomplete: 'off' })
    merged_input_options = merge_wrapper_options(merged_input_options, { value: object.send(attribute_name).strftime('%d.%m.%Y') }) if object.send(attribute_name).present?
    @builder.text_field(attribute_name, merged_input_options)
  end
end
