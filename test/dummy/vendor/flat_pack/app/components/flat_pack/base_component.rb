# frozen_string_literal: true

module FlatPack
  class BaseComponent < ViewComponent::Base
    # System arguments pattern for consistent API across components
    # Handles: class, data, aria, id, and other HTML attributes
    def initialize(**system_arguments)
      @system_arguments = sanitize_args(system_arguments)
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

    # Attach default validation hooks to field attributes so every input-like
    # component participates in shared JS validation unless explicitly disabled.
    def apply_default_validation(attrs, error_id:, has_error:, type: nil)
      return attrs unless validation_enabled?

      merged = attrs.dup
      merged[:data] = merge_data_attributes(
        merged[:data],
        validation_data_attributes(error_id: error_id, type: type)
      )

      merged[:aria] = merge_aria_attributes(
        merged[:aria],
        error_id: error_id,
        has_error: has_error
      )

      merged
    end

    # Sanitize system arguments to prevent XSS attacks
    # Filters out dangerous HTML attributes like onclick, onmouseover, etc.
    def sanitize_args(args)
      FlatPack::AttributeSanitizer.sanitize_attributes(args)
    end

    def validation_enabled?
      flag = data_attributes[:flat_pack_validate]
      flag = data_attributes["flat_pack_validate"] if flag.nil?
      existing_controller = data_attributes[:controller]
      existing_controller = data_attributes["controller"] if existing_controller.nil?

      return false if existing_controller.present?

      return true if flag.nil?

      ![false, 0, "0", "false"].include?(flag)
    end

    def validation_data_attributes(error_id:, type: nil)
      data = {
        controller: "flat-pack--form-validation",
        flat_pack__form_validation_error_id_value: error_id
      }

      data[:flat_pack__form_validation_type_value] = type if type
      data
    end

    def merge_data_attributes(existing_data, additional_data)
      existing = (existing_data || {}).dup
      additional = (additional_data || {}).dup

      merged = existing
        .except(:controller, :action, "controller", "action")
        .merge(additional.except(:controller, :action, "controller", "action"))

      merged_controllers = merge_space_tokens(
        existing[:controller] || existing["controller"],
        additional[:controller] || additional["controller"]
      )

      merged_actions = merge_space_tokens(
        existing[:action] || existing["action"],
        additional[:action] || additional["action"]
      )

      merged[:controller] = merged_controllers if merged_controllers
      merged[:action] = merged_actions if merged_actions
      merged
    end

    def merge_aria_attributes(existing_aria, error_id:, has_error:)
      merged = (existing_aria || {}).dup
      described_by = merged[:describedby] || merged["describedby"]
      tokens = described_by.to_s.split

      if has_error
        tokens << error_id unless tokens.include?(error_id)
        merged[:invalid] = "true"
      end

      merged[:describedby] = tokens.join(" ") if tokens.any?
      merged
    end

    def merge_space_tokens(left_value, right_value)
      tokens = [left_value, right_value].compact.flat_map { |value| value.to_s.split }
      return nil if tokens.empty?

      tokens.uniq.join(" ")
    end
  end
end
