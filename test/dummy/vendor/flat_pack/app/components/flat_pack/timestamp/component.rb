# frozen_string_literal: true

module FlatPack
  module Timestamp
    class Component < FlatPack::BaseComponent
      include ActionView::Helpers::DateHelper

      DEFAULT_TOOLTIP_FORMAT = "%e %b %Y %l:%M%P"

      def initialize(timestamp:, tooltip_placement: :top, fallback_text: "-", class_name: nil, **system_arguments)
        super(**system_arguments)
        @timestamp_value = timestamp
        @tooltip_placement = tooltip_placement.to_sym
        @fallback_text = fallback_text.to_s
        @class_name = class_name.to_s.presence
        @parsed_timestamp = normalize_timestamp(@timestamp_value)

        validate_tooltip_placement!
      end

      def call
        return content_tag(:span, @fallback_text, **fallback_attributes) unless @parsed_timestamp

        tooltip_component.render_in(view_context) do
          content_tag(:time, relative_timestamp_label, **time_attributes)
        end
      end

      private

      def tooltip_component
        FlatPack::Tooltip::Component.new(
          text: server_formatted_timestamp,
          placement: @tooltip_placement,
          **@system_arguments
        )
      end

      def fallback_attributes
        merge_attributes(class: timestamp_classes("flat-pack-timestamp", "inline-flex"))
      end

      def time_attributes
        {
          class: timestamp_classes("flat-pack-timestamp", "cursor-help"),
          datetime: @parsed_timestamp.iso8601,
          data: {
            controller: "flat-pack--timestamp",
            "flat-pack--timestamp-iso-value": @parsed_timestamp.iso8601,
            "flat-pack--timestamp-fallback-value": server_formatted_timestamp,
            "flat-pack--timestamp-format-value": DEFAULT_TOOLTIP_FORMAT
          }
        }
      end

      def timestamp_classes(*base_classes)
        TailwindMerge::Merger.new.merge([*base_classes, "mb-0", @class_name].compact.join(" "))
      end

      def relative_timestamp_label
        now = Time.current
        distance = time_ago_in_words(@parsed_timestamp)
        suffix = (@parsed_timestamp > now) ? "from now" : "ago"

        "#{distance} #{suffix}"
      end

      def server_formatted_timestamp
        @parsed_timestamp.strftime(DEFAULT_TOOLTIP_FORMAT)
      end

      def normalize_timestamp(value)
        return nil if value.blank?

        case value
        when ActiveSupport::TimeWithZone
          value
        when Time
          value.in_time_zone
        when DateTime
          value.to_time.in_time_zone
        when Date
          value.in_time_zone
        when Numeric
          Time.zone.at(value)
        else
          Time.zone.parse(value.to_s)
        end
      rescue ArgumentError, TypeError
        nil
      end

      def validate_tooltip_placement!
        return if FlatPack::Tooltip::Component::PLACEMENTS.key?(@tooltip_placement)

        valid = FlatPack::Tooltip::Component::PLACEMENTS.keys.join(", ")
        raise ArgumentError, "Invalid tooltip_placement: #{@tooltip_placement}. Must be one of: #{valid}"
      end
    end
  end
end
