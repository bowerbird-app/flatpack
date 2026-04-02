# frozen_string_literal: true

module FlatPack
  module Picker
    class ClientConfig
      def initialize(config:, items:, form:)
        @config = config
        @items = items
        @form = form
      end

      def data_attributes
        {
          flat_pack__picker_config_value: structured_config.to_json
        }.compact
      end

      private

      def structured_config
        {
          pickerId: @config.id,
          items: @items,
          presentation: @config.presentation,
          selection: @config.selection,
          search: @config.search,
          output: @config.output.merge(
            form: @form.client_attributes
          ),
          context: @config.context,
          emptyStateText: @config.empty_state_text
        }
      end
    end
  end
end
