# frozen_string_literal: true

module FlatPack
  module Picker
    class ItemNormalizer
      ACCEPTED_KINDS = %w[image file record].freeze

      def self.call(items)
        new(items).call
      end

      def self.normalize_kinds(kinds)
        normalized = Array(kinds).map { |kind| normalize_kind(kind) }.uniq
        normalized.presence || ACCEPTED_KINDS
      end

      def self.normalize_kind(kind)
        normalized = kind.to_s
        ACCEPTED_KINDS.include?(normalized) ? normalized : "file"
      end

      def initialize(items)
        @items = items
      end

      def call
        Array(@items).filter_map.with_index do |item, index|
          normalize_item(item, index)
        end
      end

      private

      def normalize_item(item, index)
        source = item.respond_to?(:to_h) ? item.to_h : {}
        name = fetch_value(source, :name)
        return unless name

        {
          "id" => fetch_value(source, :id) || "picker-item-#{index}",
          "kind" => self.class.normalize_kind(fetch_raw_value(source, :kind)),
          "label" => fetch_value(source, :label) || name,
          "name" => name,
          "contentType" => fetch_value(source, :content_type, :contentType),
          "byteSize" => normalize_size(fetch_raw_value(source, :byte_size, :byteSize)),
          "thumbnailUrl" => fetch_value(source, :thumbnail_url, :thumbnailUrl),
          "description" => fetch_value(source, :description),
          "path" => fetch_value(source, :path),
          "badge" => fetch_value(source, :badge),
          "meta" => fetch_value(source, :meta),
          "payload" => normalize_payload(fetch_raw_value(source, :payload))
        }.compact
      end

      def normalize_size(value)
        parsed = Integer(value, exception: false)
        parsed&.positive? ? parsed : nil
      end

      def normalize_payload(payload)
        return {} unless payload.is_a?(Hash)

        payload.deep_stringify_keys
      end

      def fetch_value(source, *keys)
        value = fetch_raw_value(source, *keys)
        return unless value.respond_to?(:presence)

        value.presence
      end

      def fetch_raw_value(source, *keys)
        keys.each do |key|
          return source[key] if source.key?(key)

          string_key = key.to_s
          return source[string_key] if source.key?(string_key)
        end

        nil
      end
    end
  end
end
