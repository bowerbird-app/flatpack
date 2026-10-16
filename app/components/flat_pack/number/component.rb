# frozen_string_literal: true

module FlatPack
  module Number
    class Component < FlatPack::BaseComponent
      FORMATS = Format::FORMATS
      ANIMATIONS = %i[count roll fade none].freeze
      DURATIONS = %i[fast base slow].freeze
      TAGS = FlatPack::Motion::TAGS
      DECIMAL_LIMIT = 20

      def initialize(value:, from: 0, format: :number, currency: nil, decimals: nil, prefix: nil, suffix: nil, duration: :slow, animate: :count, tag: :span, **system_arguments)
        super(**system_arguments)
        @value = Format.decimal(value, name: :value)
        @from = Format.decimal(from, name: :from)
        @format = choice!(format, FORMATS, :format)
        @currency = currency!(currency)
        @decimals = decimals!(decimals)
        @prefix = text!(prefix, :prefix)
        @suffix = text!(suffix, :suffix)
        @duration = choice!(duration, DURATIONS, :duration)
        @animate = choice!(animate, ANIMATIONS, :animate)
        @tag = tag
        @locale = I18n.locale.to_s.tr("_", "-")
      end

      def call
        content_tag(root_tag, **root_attributes) do
          safe_join([
            content_tag(:span, visible_text, class: "fp-number__sizer", aria: {hidden: true}, data: {flat_pack__number_target: "sizer"}),
            content_tag(:span, visible_text, class: "fp-number__final", data: {flat_pack__number_target: "final"}),
            content_tag(:span, "", class: "fp-number__stage", aria: {hidden: true}, data: {flat_pack__number_target: "stage"})
          ])
        end
      end

      private

      def visible_text
        Format.text(@value, format: @format, currency: @currency, decimals: @decimals, prefix: @prefix, suffix: @suffix)
      end

      def from_text
        Format.new(@from, format: @format, currency: @currency, decimals: @decimals).body
      end

      def root_tag
        name = @tag.to_sym
        return name if TAGS.include?(name)

        raise ArgumentError, "Invalid tag: #{@tag}. Must be one of: #{TAGS.join(", ")}"
      end

      def root_attributes
        user_style = @system_arguments.delete(:style)
        duration_style = "--fp-number-duration: var(--motion-duration-#{@duration})"
        style = [user_style.presence, duration_style].compact.join("; ")
        classes = ["fp-number", "fp-number--#{@animate}"]
        classes << "is-static" if @animate == :none

        merge_attributes(class: classes.join(" "), data: stimulus_data, style: style)
      end

      def stimulus_data
        data = {
          controller: "flat-pack--number",
          flat_pack__number_value_value: attribute_number(@value),
          flat_pack__number_from_value: attribute_number(@from),
          flat_pack__number_format_value: @format,
          flat_pack__number_duration_value: @duration,
          flat_pack__number_animate_value: @animate,
          flat_pack__number_locale_value: @locale,
          flat_pack__number_from_text_value: from_text
        }
        data[:flat_pack__number_currency_value] = @currency if @currency
        data[:flat_pack__number_decimals_value] = @decimals unless @decimals.nil?
        data[:flat_pack__number_prefix_value] = @prefix if @prefix.present?
        data[:flat_pack__number_suffix_value] = @suffix if @suffix.present?
        data
      end

      def attribute_number(number)
        number.to_s("F").sub(/\.0+\z/, "").sub(/(\.\d*?)0+\z/, "\\1")
      end

      def currency!(currency)
        if @format == :currency
          code = currency.to_s
          raise ArgumentError, "currency is required" unless code.match?(/\A[A-Z]{3}\z/)

          return code
        end

        raise ArgumentError, "currency: is only used with format: :currency" if currency.present?

        nil
      end

      def decimals!(decimals)
        return nil if decimals.nil?
        return decimals if decimals.is_a?(Integer) && decimals.between?(0, DECIMAL_LIMIT)

        raise ArgumentError, "decimals must be an integer from 0 to #{DECIMAL_LIMIT}"
      end

      def text!(value, name)
        validate_text_option!(value, name: name)
        value.to_s
      end

      def choice!(value, allowed, name)
        choice = value.to_sym
        return choice if allowed.include?(choice)

        raise ArgumentError, "Invalid #{name}: #{value}. Must be one of: #{allowed.join(", ")}"
      end
    end
  end
end
