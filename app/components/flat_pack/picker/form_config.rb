# frozen_string_literal: true

module FlatPack
  module Picker
    class FormConfig
      VALUE_MODES = %i[id ids json].freeze

      def initialize(form:, selection_mode:)
        @selection_mode = selection_mode
        @present = form.present?
        return unless @present

        source = normalize_source(form)

        @url = source[:url].present? ? FlatPack::AttributeSanitizer.sanitize_url(source[:url]) : nil
        @method = normalize_method(source[:method])
        @scope = source[:scope].presence&.to_s
        @field = source[:field].presence&.to_s
        @value_mode = normalize_value_mode(source[:value_mode])
        @value_path = source[:value_path].presence&.to_s || "id"
        @turbo = source.key?(:turbo) ? !!source[:turbo] : true

        validate!
      end

      attr_reader :field, :method, :scope, :turbo, :url, :value_mode, :value_path

      def present?
        @present
      end

      def blank?
        !present?
      end

      def form_with_attributes
        return {} unless present?

        {
          url: @url,
          method: @method,
          scope: @scope,
          data: {
            turbo: @turbo
          },
          html: {
            class: "h-full"
          }
        }.compact
      end

      def client_attributes
        return nil unless present?

        {
          field: @field,
          scope: @scope,
          valueMode: @value_mode,
          valuePath: @value_path
        }
      end

      def client_value
        client_attributes&.to_json
      end

      private

      def normalize_source(form)
        return {} unless form.respond_to?(:to_h)

        form.to_h.deep_symbolize_keys
      end

      def normalize_method(method)
        return :post if method.blank?

        method.to_sym
      end

      def normalize_value_mode(value_mode)
        return ((@selection_mode == :multiple) ? :ids : :id) if value_mode.blank?

        value_mode.to_sym
      end

      def validate!
        raise ArgumentError, "form[:url] is required when form mode is enabled" unless @url.present?
        raise ArgumentError, "form[:field] is required when form mode is enabled" unless @field.present?

        unless VALUE_MODES.include?(@value_mode)
          raise ArgumentError, "Invalid form value_mode: #{@value_mode}. Must be one of: #{VALUE_MODES.join(", ")}."
        end

        if @selection_mode == :multiple && @value_mode == :id
          raise ArgumentError, "form[:value_mode] cannot be :id when selection_mode is :multiple"
        end

        if @selection_mode == :single && @value_mode == :ids
          raise ArgumentError, "form[:value_mode] cannot be :ids when selection_mode is :single"
        end
      end
    end
  end
end
