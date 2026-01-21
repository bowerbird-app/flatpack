# frozen_string_literal: true

module FlatPack
  class BaseComponent < ViewComponent::Base
    # System arguments pattern for consistent API across components
    # Handles: class, data, aria, id, and other HTML attributes
    def initialize(**system_arguments)
      @system_arguments = system_arguments
    end

    private

    # Extract and merge classes using tailwind_merge
    def classes(*additional_classes)
      base_classes = @system_arguments.delete(:class) || ""
      merger = TailwindMerge::Merger.new
      merger.merge([base_classes, *additional_classes].compact.join(" "))
    end

    # Extract data attributes
    def data_attributes
      @system_arguments.fetch(:data, {})
    end

    # Extract aria attributes
    def aria_attributes
      @system_arguments.fetch(:aria, {})
    end

    # Get all system arguments except class, data, aria
    def html_attributes
      @system_arguments.except(:class, :data, :aria)
    end

    # Merge all attributes for rendering
    def merge_attributes(**additional_attrs)
      {
        class: classes(additional_attrs.delete(:class)),
        data: data_attributes.merge(additional_attrs.delete(:data) || {}),
        aria: aria_attributes.merge(additional_attrs.delete(:aria) || {})
      }.merge(html_attributes).merge(additional_attrs).compact
    end
  end
end
