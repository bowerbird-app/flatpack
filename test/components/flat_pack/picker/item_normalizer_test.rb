# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Picker
    class ItemNormalizerTest < ActiveSupport::TestCase
      def test_normalizes_string_and_camel_case_keys_into_stable_item_shape
        items = ItemNormalizer.call([
          {
            "id" => "asset-1",
            "kind" => "image",
            "name" => "hero.png",
            "label" => "Hero",
            "contentType" => "image/png",
            "byteSize" => "1024",
            "thumbnailUrl" => "https://example.com/hero.png",
            "payload" => {
              signed_id: "abc123"
            }
          }
        ])

        assert_equal [{
          "id" => "asset-1",
          "kind" => "image",
          "label" => "Hero",
          "name" => "hero.png",
          "contentType" => "image/png",
          "byteSize" => 1024,
          "thumbnailUrl" => "https://example.com/hero.png",
          "payload" => {
            "signed_id" => "abc123"
          }
        }], items
      end

      def test_skips_items_without_name_and_falls_back_unknown_kinds_to_file
        items = ItemNormalizer.call([
          {label: "Missing name"},
          {name: "brief.pdf", kind: :unknown}
        ])

        assert_equal 1, items.length
        assert_equal "file", items.first.fetch("kind")
        assert_equal "brief.pdf", items.first.fetch("label")
      end

      def test_normalize_kinds_defaults_back_to_supported_picker_kinds
        assert_equal %w[image file record], ItemNormalizer.normalize_kinds([])
        assert_equal %w[file], ItemNormalizer.normalize_kinds([:unknown, "file"])
      end
    end
  end
end
