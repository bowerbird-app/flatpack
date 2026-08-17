# frozen_string_literal: true

module FlatPack
  module List
    class Component < FlatPack::BaseComponent
      def initialize(
        ordered: false,
        spacing: :comfortable,
        divider: false,
        selectable: false,
        orderable: false,
        orderable_url: nil,
        orderable_method: :patch,
        param_uuid_name: "id",
        param_target_position_name: "position",
        **system_arguments
      )
        super(**system_arguments)
        @ordered = ordered
        @spacing = spacing.to_sym
        @divider = divider
        @selectable = selectable
        @orderable = orderable
        @orderable_url = orderable_url
        @orderable_method = orderable_method
        @param_uuid_name = param_uuid_name
        @param_target_position_name = param_target_position_name
      end

      def call
        tag_name = @ordered ? :ol : :ul

        # SECURITY: Content is marked html_safe because it's expected to contain
        # Rails-generated HTML from list items captured via block. Never pass
        # unsanitized user input directly to content.
        content_tag(tag_name, content.to_s.html_safe, **list_attributes)
      end

      private

      def list_attributes
        attrs = {
          class: list_classes,
          role: "list"
        }

        attrs[:data] = orderable_data_attributes if @orderable

        if @selectable
          attrs[:data] ||= {}
          attrs[:data][:controller] = merge_space_tokens(attrs[:data][:controller], "flat-pack--list-selectable")
          attrs[:data][:action] = merge_space_tokens(attrs[:data][:action], "click->flat-pack--list-selectable#activate")
          attrs[:data][:flat_pack__list_selectable_active_class_value] = "bg-[var(--list-item-active-background-color)]"
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

        data
      end

      def list_classes
        classes(
          (@spacing == :dense) ? "space-y-1" : "space-y-3",
          ("divide-y divide-[var(--surface-border-color)]" if @divider)
        )
      end

      def merge_space_tokens(left_value, right_value)
        tokens = [left_value, right_value].compact.flat_map { |value| value.to_s.split }
        return nil if tokens.empty?

        tokens.uniq.join(" ")
      end
    end
  end
end
