# frozen_string_literal: true

module FlatPack
  module Number
    # English grouping and currency marks follow Intl.NumberFormat.
    # The delimiter and separator come from the host locale.
    class Format
      FORMATS = %i[number currency percent compact].freeze
      ZERO_DECIMAL_CURRENCIES = %w[JPY KRW VND].freeze
      COMPACT_SUFFIXES = {3 => "K", 6 => "M", 9 => "B", 12 => "T"}.freeze
      CURRENCY_MARKS = {
        "USD" => "$",
        "EUR" => "€",
        "GBP" => "£",
        "JPY" => "¥",
        "KRW" => "₩",
        "VND" => "₫",
        "CNY" => "CN¥",
        "AUD" => "A$",
        "CAD" => "CA$",
        "INR" => "₹",
        "BRL" => "R$",
        "MXN" => "MX$",
        "NZD" => "NZ$",
        "HKD" => "HK$",
        "ILS" => "₪"
      }.freeze

      def self.text(value, format: :number, currency: nil, decimals: nil, prefix: nil, suffix: nil)
        new(value, format: format, currency: currency, decimals: decimals, prefix: prefix, suffix: suffix).to_s
      end

      def self.decimal(value, name: :value)
        case value
        when Integer
          BigDecimal(value)
        when BigDecimal
          raise ArgumentError, "#{name} must be a finite number" unless value.finite?

          value
        when Float
          raise ArgumentError, "#{name} must be a finite number" unless value.finite?

          BigDecimal(value.to_s)
        when String
          if (value.respond_to?(:html_safe?) && value.html_safe?) || !value.match?(/\A-?(?:\d+\.?\d*|\.\d+)\z/)
            raise ArgumentError, "#{name} must be a number"
          end

          BigDecimal(value)
        else
          raise ArgumentError, "#{name} must be a number"
        end
      end

      def initialize(value, format: :number, currency: nil, decimals: nil, prefix: nil, suffix: nil)
        @value = self.class.decimal(value)
        @format = format.to_sym
        @currency = currency
        @decimals = decimals
        @prefix = prefix.to_s
        @suffix = suffix.to_s
      end

      def to_s
        "#{@prefix}#{body}#{@suffix}"
      end

      def body
        case @format
        when :currency then currency_body
        when :percent then percent_body
        when :compact then compact_body
        else number_body
        end
      end

      private

      def number_body
        minimum, maximum = fraction_digits(default_min: 0, default_max: 3)
        format_fixed(@value, min: minimum, max: maximum)
      end

      def currency_body
        digits = @decimals || (ZERO_DECIMAL_CURRENCIES.include?(@currency) ? 0 : 2)
        amount = format_fixed(@value.abs, min: digits, max: digits)
        sign = @value.negative? ? "-" : ""
        "#{sign}#{currency_mark}#{amount}"
      end

      def percent_body
        minimum, maximum = fraction_digits(default_min: 0, default_max: 0)
        "#{format_fixed(@value * 100, min: minimum, max: maximum)}%"
      end

      def compact_body
        absolute = @value.abs
        sign = @value.negative? ? "-" : ""
        "#{sign}#{compact_amount(absolute)}"
      end

      def compact_amount(absolute)
        exponent, suffix = compact_tier(absolute)
        4.times do
          scaled = absolute / (BigDecimal(10)**exponent)
          if @decimals.nil?
            maximum = (exponent.positive? && scaled < 10) ? 1 : 0
            minimum = 0
          else
            minimum = @decimals
            maximum = @decimals
          end
          rounded = scaled.round(maximum, BigDecimal::ROUND_HALF_UP)
          if rounded >= 1000 && exponent < 12
            exponent += 3
            suffix = COMPACT_SUFFIXES.fetch(exponent)
            next
          end
          return "#{format_fixed(rounded, min: minimum, max: maximum, grouping: :compact)}#{suffix}"
        end
        format_fixed(absolute, min: 0, max: 0)
      end

      def compact_tier(absolute)
        COMPACT_SUFFIXES.keys.sort.reverse_each do |exponent|
          return [exponent, COMPACT_SUFFIXES.fetch(exponent)] if absolute >= (BigDecimal(10)**exponent)
        end
        [0, ""]
      end

      def fraction_digits(default_min:, default_max:)
        return [@decimals, @decimals] unless @decimals.nil?

        [default_min, default_max]
      end

      def format_fixed(number, min:, max:, grouping: :standard)
        rounded = number.round(max, BigDecimal::ROUND_HALF_UP)
        negative = rounded.negative?
        whole, fraction = rounded.abs.to_s("F").split(".", 2)
        fraction = "" if max.zero?
        unless max.zero?
          fraction = fraction.to_s[0, max].to_s.ljust(max, "0")
          fraction = fraction.sub(/0+\z/, "") if fraction.length > min
          fraction = fraction.ljust(min, "0")
        end
        text = (grouping == :compact && whole.length < 5) ? whole : group_digits(whole)
        text = "#{text}#{separator}#{fraction}" if fraction.present?
        negative ? "-#{text}" : text
      end

      def group_digits(whole)
        whole.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{delimiter}").reverse
      end

      def currency_mark
        CURRENCY_MARKS.fetch(@currency) { "#{@currency}\u00A0" }
      end

      def delimiter
        I18n.t("number.format.delimiter", default: ",")
      end

      def separator
        I18n.t("number.format.separator", default: ".")
      end
    end
  end
end
