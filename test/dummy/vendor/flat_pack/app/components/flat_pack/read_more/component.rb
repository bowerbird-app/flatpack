# frozen_string_literal: true

module FlatPack
  module ReadMore
    class Component < FlatPack::BaseComponent
      def initialize(
        lines: 4,
        open: false,
        more_label: FlatPack::Copy::OMITTED,
        less_label: FlatPack::Copy::OMITTED,
        **system_arguments
      )
        super(**system_arguments)
        @lines = lines
        @open = open
        validate_lines!
        validate_open!
        @more_label = resolved_label(more_label, "read_more.more", :more_label)
        @less_label = resolved_label(less_label, "read_more.less", :less_label)
        @clip_id = clip_id_for(@system_arguments[:id])
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([clip, toggle])
        end
      end

      private

      def clip
        content_tag(:div, **clip_attributes) do
          safe_join([line_box, content_tag(:div, content, **body_attributes)])
        end
      end

      def line_box
        tag.span(
          class: "fp-read-more-line",
          aria: {hidden: true},
          data: {flat_pack__read_more_target: "line"}
        )
      end

      def toggle
        render FlatPack::Button::Component.new(
          text: (@open ? @less_label : @more_label),
          style: :ghost,
          size: :sm,
          type: "button",
          hidden: true,
          aria: {expanded: (@open ? "true" : "false"), controls: @clip_id},
          data: {
            flat_pack__read_more_target: "toggle",
            action: "click->flat-pack--read-more#toggle"
          }
        )
      end

      def root_attributes
        attrs = merge_attributes(
          class: "fp-read-more",
          data: merge_data_attributes(data_attributes, {
            controller: "flat-pack--read-more",
            flat_pack__read_more_open_value: @open,
            flat_pack__read_more_more_label_value: @more_label,
            flat_pack__read_more_less_label_value: @less_label
          })
        )
        attrs[:style] = join_styles(attrs[:style], "--read-more-lines: #{@lines}")
        attrs
      end

      def clip_attributes
        {
          id: @clip_id,
          class: "fp-read-more-clip"
        }
      end

      def body_attributes
        {
          class: "fp-read-more-body",
          data: {flat_pack__read_more_target: "body"}
        }
      end

      def clip_id_for(root_id)
        return "#{root_id}-content" if root_id.present?

        "fp-read-more-#{SecureRandom.hex(4)}"
      end

      def resolved_label(given, key, name)
        validate_text_option!(given, name: name) unless given.equal?(FlatPack::Copy::OMITTED)
        label = fp_text(given, key)
        return label if label.is_a?(String) && label.present?

        raise ArgumentError, "#{name} must be a String"
      end

      def validate_lines!
        return if @lines.is_a?(Integer) && @lines.positive?

        raise ArgumentError, "lines must be a positive integer"
      end

      def validate_open!
        return if @open == true || @open == false

        raise ArgumentError, "open must be true or false"
      end
    end
  end
end
