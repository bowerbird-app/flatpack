# frozen_string_literal: true

module PagesHelper
  def demo_button_basic_examples
    [
      {label: "Primary", kwargs: {text: "Primary", style: :primary}},
      {label: "Secondary", kwargs: {text: "Secondary", style: :secondary}},
      {label: "Ghost", kwargs: {text: "Ghost", style: :ghost}},
      {label: "Success", kwargs: {text: "Success", style: :success}},
      {label: "Warning", kwargs: {text: "Warning", style: :warning}}
    ]
  end

  def demo_button_snippets(examples)
    examples.map do |example|
      {
        label: example[:label],
        language: "erb",
        code: demo_component_render_code("FlatPack::Button::Component", example.fetch(:kwargs))
      }
    end
  end

  private

  def demo_component_render_code(component_name, kwargs)
    rendered_kwargs = kwargs.map { |key, value| "#{key}: #{demo_code_value(value)}" }.join(", ")
    "<%= render #{component_name}.new(#{rendered_kwargs}) %>"
  end

  def demo_code_value(value)
    case value
    when Symbol
      ":#{value}"
    when String
      value.inspect
    else
      value.inspect
    end
  end
end