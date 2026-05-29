# frozen_string_literal: true

module FlatPack
  module ChartButtons
    class ButtonComponent < FlatPack::BaseComponent
      def initialize(
        text:,
        url:,
        selected: false,
        style: nil,
        size: :sm,
        turbo_frame: nil,
        turbo_prefetch: false,
        data: {},
        aria: {},
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @url = url
        @selected = selected
        @style = style || (@selected ? :primary : :secondary)
        @size = size
        @turbo_frame = turbo_frame
        @turbo_prefetch = turbo_prefetch
        @data = merge_turbo_data(data)
        @aria = {pressed: @selected}.merge(aria || {})
      end

      def call
        render FlatPack::Button::Component.new(
          text: @text,
          url: @url,
          style: @style,
          size: @size,
          data: @data,
          aria: @aria,
          **@system_arguments
        )
      end

      private

      def merge_turbo_data(data)
        merged = (data || {}).dup

        frame_override = merged.delete(:turbo_frame) || merged.delete("turbo_frame")
        prefetch_override = merged.delete(:turbo_prefetch) || merged.delete("turbo_prefetch")

        frame_value = frame_override.nil? ? @turbo_frame : frame_override
        prefetch_value = prefetch_override.nil? ? @turbo_prefetch : prefetch_override

        merged[:turbo_frame] = frame_value if frame_value.present?
        merged[:turbo_prefetch] = prefetch_value unless prefetch_value.nil?
        merged
      end
    end
  end
end
