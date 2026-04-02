# frozen_string_literal: true

module FlatPack
  module Picker
    class Config
      SELECTION_MODES = %i[single multiple].freeze
      SEARCH_MODES = %i[local remote].freeze
      OUTPUT_MODES = %i[event field].freeze
      RESULTS_LAYOUTS = %i[list grid].freeze

      def initialize(
        id:,
        title:,
        subtitle:,
        confirm_text:,
        close_text:,
        size:,
        selection_mode:,
        accepted_kinds:,
        searchable:,
        search_placeholder:,
        search_mode:,
        search_endpoint:,
        search_param:,
        output_mode:,
        output_target:,
        context:,
        empty_state_text:,
        results_layout:,
        modal:,
        auto_confirm:,
        modal_body_height_mode:,
        modal_body_height:
      )
        @id = id
        @title = title
        @subtitle = subtitle
        @confirm_text = confirm_text
        @close_text = close_text
        @size = size
        @selection_mode = selection_mode.to_sym
        @accepted_kinds = ItemNormalizer.normalize_kinds(accepted_kinds)
        @searchable = !!searchable
        @search_placeholder = search_placeholder
        @search_mode = search_mode.to_sym
        @search_endpoint = search_endpoint.present? ? FlatPack::AttributeSanitizer.sanitize_url(search_endpoint) : nil
        @search_param = search_param
        @output_mode = output_mode.to_sym
        @output_target = output_target
        @context = context.is_a?(Hash) ? context : {}
        @empty_state_text = empty_state_text
        @results_layout = results_layout.to_sym
        @modal = !!modal
        @auto_confirm = !!auto_confirm
        @modal_body_height_mode = modal_body_height_mode
        @modal_body_height = modal_body_height
        @original_search_endpoint = search_endpoint

        validate!
      end

      attr_reader :accepted_kinds, :close_text, :confirm_text, :context, :empty_state_text, :id,
        :modal_body_height, :modal_body_height_mode, :output_mode, :output_target, :results_layout,
        :search_endpoint, :search_mode, :search_param, :search_placeholder, :selection_mode, :size,
        :subtitle, :title

      def auto_confirm?
        @auto_confirm
      end

      def modal?
        @modal
      end

      def auto_confirm_single_select?
        @selection_mode == :single && @auto_confirm
      end

      def presentation
        {
          modal: @modal,
          resultsLayout: @results_layout
        }
      end

      def selection
        {
          mode: @selection_mode,
          acceptedKinds: @accepted_kinds,
          autoConfirm: @auto_confirm
        }
      end

      def search
        {
          enabled: @searchable,
          mode: @search_mode,
          endpoint: @search_endpoint,
          param: @search_param
        }
      end

      def output
        {
          mode: @output_mode,
          target: @output_target
        }
      end

      private

      def validate!
        validate_id!
        validate_selection_mode!
        validate_search_mode!
        validate_output_mode!
        validate_results_layout!
        validate_search_configuration!
        validate_search_endpoint!
      end

      def validate_id!
        return if @id.present?

        raise ArgumentError, "id is required"
      end

      def validate_selection_mode!
        return if SELECTION_MODES.include?(@selection_mode)

        raise ArgumentError, "Invalid selection_mode: #{@selection_mode}. Must be one of: #{SELECTION_MODES.join(", ")}."
      end

      def validate_search_mode!
        return if SEARCH_MODES.include?(@search_mode)

        raise ArgumentError, "Invalid search_mode: #{@search_mode}. Must be one of: #{SEARCH_MODES.join(", ")}."
      end

      def validate_output_mode!
        return if OUTPUT_MODES.include?(@output_mode)

        raise ArgumentError, "Invalid output_mode: #{@output_mode}. Must be one of: #{OUTPUT_MODES.join(", ")}."
      end

      def validate_results_layout!
        return if RESULTS_LAYOUTS.include?(@results_layout)

        raise ArgumentError, "Invalid results_layout: #{@results_layout}. Must be one of: #{RESULTS_LAYOUTS.join(", ")}."
      end

      def validate_search_configuration!
        return unless @search_mode == :remote && @searchable
        return if @search_endpoint.present?

        raise ArgumentError, "search_endpoint is required when searchable is true and search_mode is :remote"
      end

      def validate_search_endpoint!
        return unless @original_search_endpoint.present?
        return if @search_endpoint.present?

        raise ArgumentError, "Unsafe search_endpoint detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
