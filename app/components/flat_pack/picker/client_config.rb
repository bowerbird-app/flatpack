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
          flat_pack__picker_config_value: structured_config.to_json,
          flat_pack__picker_picker_id_value: @config.id,
          flat_pack__picker_items_value: @items.to_json,
          flat_pack__picker_selection_mode_value: @config.selection_mode,
          flat_pack__picker_accepted_kinds_value: @config.accepted_kinds.to_json,
          flat_pack__picker_searchable_value: @config.search.fetch(:enabled),
          flat_pack__picker_search_mode_value: @config.search.fetch(:mode),
          flat_pack__picker_search_endpoint_value: @config.search.fetch(:endpoint),
          flat_pack__picker_search_param_value: @config.search.fetch(:param),
          flat_pack__picker_output_mode_value: @config.output.fetch(:mode),
          flat_pack__picker_output_target_value: @config.output.fetch(:target),
          flat_pack__picker_context_value: @config.context.to_json,
          flat_pack__picker_empty_state_text_value: @config.empty_state_text,
          flat_pack__picker_results_layout_value: @config.results_layout,
          flat_pack__picker_modal_value: @config.modal?,
          flat_pack__picker_auto_confirm_value: @config.auto_confirm?,
          flat_pack__picker_form_value: @form.client_value
        }.compact
      end

      private

      def structured_config
        {
          pickerId: @config.id,
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
