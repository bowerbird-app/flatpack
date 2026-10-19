# frozen_string_literal: true

module FlatPack
  module List
    class Component < FlatPack::BaseComponent
      # :items keeps today's <ul>/<ol>. :key_value renders a <dl> of key/value rows.
      LAYOUTS = %i[items key_value].freeze
      STACK_BELOWS = %i[sm md lg].freeze
      CSS_LENGTH_PATTERN = /\A\d+(?:\.\d+)?(?:px|rem|em|ch|ex|vw|vh|vmin|vmax|%)\z/

      def initialize(
        layout: :items,
        key_width: :fit,
        stack_below: nil,
        ordered: false,
        spacing: :comfortable,
        divider: false,
        selectable: false,
        orderable: false,
        orderable_url: nil,
        orderable_method: :patch,
        param_uuid_name: "id",
        param_target_position_name: "position",
        handle_selector: nil,
        **system_arguments
      )
        super(**system_arguments)
        @layout = normalize_layout(layout)
        @key_width = key_width
        @stack_below = normalize_stack_below(stack_below)
        @ordered = ordered
        @spacing = spacing.to_sym
        @divider = divider
        @selectable = selectable
        @orderable = orderable
        @orderable_url = orderable_url
        @orderable_method = orderable_method
        @param_uuid_name = param_uuid_name
        @param_target_position_name = param_target_position_name
        @handle_selector = handle_selector.presence

        validate_layout_options!
      end

      def call
        Rendering.with(layout: @layout, stack_below: @stack_below) do
          # SECURITY: Content is marked html_safe because it's expected to contain
          # Rails-generated HTML from list items captured via block. Never pass
          # unsanitized user input directly to content.
          content_tag(list_tag, content.to_s.html_safe, **list_attributes)
        end
      end

      private

      def list_tag
        return :dl if key_value?

        @ordered ? :ol : :ul
      end

      def key_value?
        @layout == :key_value
      end

      def list_attributes
        apply_key_width_variable! if key_value?

        attrs = {class: list_classes}
        attrs[:role] = "list" unless key_value?

        attrs[:data] = orderable_data_attributes if @orderable

        if @selectable
          attrs[:data] ||= {}
          attrs[:data][:controller] = merge_space_tokens(attrs[:data][:controller], "flat-pack--list-selectable")
          attrs[:data][:action] = merge_space_tokens(attrs[:data][:action], "click->flat-pack--list-selectable#activate")
          attrs[:data][:flat_pack__list_selectable_active_class_value] = "rounded-[var(--radius-sm)] bg-[var(--list-item-active-background-color)]"
        end

        merge_attributes(**attrs)
      end

      def orderable_data_attributes
        data = {
          controller: "flat-pack--list-orderable"
        }

        data[:flat_pack__list_orderable_orderable_url_value] = @orderable_url if @orderable_url.present?
        data[:flat_pack__list_orderable_orderable_method_value] = @orderable_method.to_s.upcase if @orderable_method.present?
        data[:flat_pack__list_orderable_param_uuid_name_value] = @param_uuid_name if @param_uuid_name.present?
        data[:flat_pack__list_orderable_param_target_position_name_value] = @param_target_position_name if @param_target_position_name.present?
        data[:flat_pack__list_orderable_handle_selector_value] = @handle_selector if @handle_selector.present?

        data
      end

      def list_classes
        if key_value?
          return classes(
            "flat-pack-list",
            "flat-pack-list--key-value",
            KeyValueLayout.list_classes_for(@stack_below),
            spacing_gap_class,
            ("flat-pack-list-divided" if @divider)
          )
        end

        classes(
          "flat-pack-list",
          "flex flex-col",
          ("flat-pack-list--orderable" if @orderable),
          # Orderable + divided lists skip gap — gap fights the divider and looks uneven while dragging.
          (spacing_gap_class unless @orderable && @divider),
          ("flat-pack-list-divided" if @divider)
        )
      end

      def spacing_gap_class
        if key_value?
          return (@spacing == :dense) ? "gap-y-1" : "gap-y-3"
        end

        (@spacing == :dense) ? "gap-1" : "gap-3"
      end

      def apply_key_width_variable!
        declaration = "--fp-list-key-width: #{key_width_css}"
        existing = @system_arguments[:style]
        @system_arguments[:style] = [declaration, existing.presence].compact.join("; ")
      end

      def key_width_css
        return "max-content" if @key_width == :fit

        @key_width
      end

      def normalize_layout(layout)
        raise ArgumentError, "layout is required." if layout.nil?

        name = layout.to_sym
        return name if LAYOUTS.include?(name)

        raise ArgumentError, "Invalid layout: #{layout.inspect}. Must be one of: #{LAYOUTS.join(", ")}."
      end

      def normalize_stack_below(stack_below)
        return if stack_below.nil?

        name = stack_below.to_sym
        return name if STACK_BELOWS.include?(name)

        raise ArgumentError, "Invalid stack_below: #{stack_below.inspect}. Must be one of: #{STACK_BELOWS.join(", ")}."
      end

      def validate_layout_options!
        if key_value?
          validate_key_value_options!
        else
          validate_items_layout_options!
        end
      end

      def validate_key_value_options!
        raise ArgumentError, "ordered: true is not supported when layout is :key_value." if @ordered
        raise ArgumentError, "orderable: true is not supported when layout is :key_value." if @orderable
        raise ArgumentError, "selectable: true is not supported when layout is :key_value." if @selectable

        validate_key_width!
      end

      def validate_items_layout_options!
        unless @key_width == :fit
          raise ArgumentError, "key_width: is only supported when layout is :key_value."
        end

        return if @stack_below.nil?

        raise ArgumentError, "stack_below: is only supported when layout is :key_value."
      end

      def validate_key_width!
        return if @key_width == :fit

        length = @key_width.strip if @key_width.is_a?(String)
        sanitized = FlatPack::AttributeSanitizer.sanitize_css_grid_track(length)
        if sanitized&.match?(CSS_LENGTH_PATTERN)
          @key_width = sanitized
          return
        end

        raise ArgumentError, "Invalid key_width: #{@key_width.inspect}. Must be :fit or a CSS length such as \"10rem\"."
      end

      def merge_space_tokens(left_value, right_value)
        tokens = [left_value, right_value].compact.flat_map { |value| value.to_s.split }
        return nil if tokens.empty?

        tokens.uniq.join(" ")
      end
    end
  end
end
