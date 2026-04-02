# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Picker
    class FormConfigTest < ActiveSupport::TestCase
      def test_defaults_value_mode_from_selection_mode_and_serializes_client_config
        config = FormConfig.new(
          form: {
            "url" => "/demo/picker_submissions",
            "field" => "asset_ids",
            "scope" => "picker_assignment",
            "value_path" => "payload.signed_id"
          },
          selection_mode: :multiple
        )

        assert_equal :ids, config.value_mode
        assert_equal({
          field: "asset_ids",
          scope: "picker_assignment",
          valueMode: :ids,
          valuePath: "payload.signed_id"
        }, config.client_attributes)
      end

      def test_rejects_single_select_ids_value_mode
        error = assert_raises(ArgumentError) do
          FormConfig.new(
            form: {
              url: "/demo/picker_submissions",
              field: :asset_ids,
              value_mode: :ids
            },
            selection_mode: :single
          )
        end

        assert_equal "form[:value_mode] cannot be :ids when selection_mode is :single", error.message
      end
    end
  end
end
