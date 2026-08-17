# frozen_string_literal: true

module FlatPack
  module ChartButtons
    class DropdownComponent < FlatPack::BaseComponent
      def initialize(
        text:,
        options:,
        style: :secondary,
        size: :sm,
        placement: :bottom_right,
        trigger_attributes: {},
        turbo_frame: nil,
        turbo_prefetch: false,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @options = Array(options)
        @style = style
        @size = size
        @placement = placement
        @trigger_attributes = trigger_attributes
        @turbo_frame = turbo_frame
        @turbo_prefetch = turbo_prefetch
      end

      def call
        dropdown = FlatPack::Button::Dropdown::Component.new(
          text: @text,
          style: @style,
          size: @size,
          placement: @placement,
          trigger_attributes: @trigger_attributes,
          **@system_arguments
        )

        @options.each do |option|
          add_dropdown_option(dropdown, option)
        end

        render dropdown
      end

      private

      def add_dropdown_option(dropdown, option)
        option_hash = (option || {}).dup

        text = delete_key(option_hash, :text)
        href = delete_key(option_hash, :url) || delete_key(option_hash, :href)
        selected = delete_key(option_hash, :selected)
        option_data = delete_key(option_hash, :data) || {}
        option_aria = delete_key(option_hash, :aria) || {}
        turbo_frame = delete_key(option_hash, :turbo_frame)
        turbo_prefetch = delete_key(option_hash, :turbo_prefetch)

        if selected
          option_aria = option_aria.merge(current: "true")
          option_hash[:icon] ||= "check"
        end

        dropdown.menu_item(
          text: text,
          href: href,
          data: merge_turbo_data(option_data, turbo_frame: turbo_frame, turbo_prefetch: turbo_prefetch),
          aria: option_aria,
          **option_hash
        )
      end

      def merge_turbo_data(data, turbo_frame: nil, turbo_prefetch: nil)
        merged = (data || {}).dup

        frame_override = turbo_frame.nil? ? delete_key(merged, :turbo_frame) : turbo_frame
        prefetch_override = turbo_prefetch.nil? ? delete_key(merged, :turbo_prefetch) : turbo_prefetch

        frame_value = frame_override.nil? ? @turbo_frame : frame_override
        prefetch_value = prefetch_override.nil? ? @turbo_prefetch : prefetch_override

        merged[:turbo_frame] = frame_value if frame_value.present?
        merged[:turbo_prefetch] = prefetch_value unless prefetch_value.nil?
        merged
      end

      def delete_key(hash, key)
        hash.delete(key) || hash.delete(key.to_s)
      end
    end
  end
end
