# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Picker
    class ClientConfigTest < ActiveSupport::TestCase
      def test_serializes_one_canonical_picker_config_payload
        config = Config.new(
          id: "picker-demo",
          title: "Select Assets",
          subtitle: "Choose one",
          confirm_text: "Use Selected",
          close_text: "Close",
          size: :lg,
          selection_mode: :single,
          accepted_kinds: [:image],
          searchable: true,
          search_placeholder: "Search assets...",
          search_mode: :remote,
          search_endpoint: "/demo/picker_results",
          search_param: "query",
          output_mode: :field,
          output_target: "#picker-output",
          context: {source: "demo"},
          empty_state_text: "No matches",
          results_layout: :grid,
          modal: true,
          auto_confirm: true,
          modal_body_height_mode: :fixed,
          modal_body_height: "24rem"
        )
        form = FormConfig.new(
          form: {
            url: "/demo/picker_submissions",
            field: :asset_id,
            scope: :picker_assignment,
            value_path: "payload.signed_id"
          },
          selection_mode: :single
        )
        client_config = ClientConfig.new(
          config: config,
          items: ItemNormalizer.call([{id: "asset-1", name: "hero.png", kind: "image"}]),
          form: form
        )

        data_attributes = client_config.data_attributes

        assert_equal [:flat_pack__picker_config_value], data_attributes.keys

        payload = JSON.parse(data_attributes.fetch(:flat_pack__picker_config_value))

        assert_equal "picker-demo", payload.fetch("pickerId")
        assert_equal [{"id" => "asset-1", "kind" => "image", "label" => "hero.png", "name" => "hero.png", "payload" => {}}], payload.fetch("items")
        assert_equal({"modal" => true, "resultsLayout" => "grid"}, payload.fetch("presentation"))
        assert_equal({"mode" => "single", "acceptedKinds" => ["image"], "autoConfirm" => true}, payload.fetch("selection"))
        assert_equal({"enabled" => true, "mode" => "remote", "endpoint" => "/demo/picker_results", "param" => "query"}, payload.fetch("search"))
        assert_equal "#picker-output", payload.dig("output", "target")
        assert_equal "asset_id", payload.dig("output", "form", "field")
      end
    end
  end
end
