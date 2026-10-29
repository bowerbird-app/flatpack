# frozen_string_literal: true

module FlatPack
  module Grid
    class Item < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "col-span-1" "col-span-2" "col-span-3" "col-span-4" "col-span-5" "col-span-6"
      # "col-span-7" "col-span-8" "col-span-9" "col-span-10" "col-span-11" "col-span-12" "col-span-full"
      # "sm:col-span-1" "sm:col-span-2" "sm:col-span-3" "sm:col-span-4" "sm:col-span-5" "sm:col-span-6"
      # "sm:col-span-7" "sm:col-span-8" "sm:col-span-9" "sm:col-span-10" "sm:col-span-11" "sm:col-span-12" "sm:col-span-full"
      # "md:col-span-1" "md:col-span-2" "md:col-span-3" "md:col-span-4" "md:col-span-5" "md:col-span-6"
      # "md:col-span-7" "md:col-span-8" "md:col-span-9" "md:col-span-10" "md:col-span-11" "md:col-span-12" "md:col-span-full"
      # "lg:col-span-1" "lg:col-span-2" "lg:col-span-3" "lg:col-span-4" "lg:col-span-5" "lg:col-span-6"
      # "lg:col-span-7" "lg:col-span-8" "lg:col-span-9" "lg:col-span-10" "lg:col-span-11" "lg:col-span-12" "lg:col-span-full"
      # "xl:col-span-1" "xl:col-span-2" "xl:col-span-3" "xl:col-span-4" "xl:col-span-5" "xl:col-span-6"
      # "xl:col-span-7" "xl:col-span-8" "xl:col-span-9" "xl:col-span-10" "xl:col-span-11" "xl:col-span-12" "xl:col-span-full"
      # "fp-grid__item"
      SPAN_COUNTS = (1..12)

      def initialize(span: nil, **system_arguments)
        super(**system_arguments)
        @span = normalize_span(span)
        validate_span!
      end

      def call
        content_tag(:div, content, **item_attributes)
      end

      private

      def item_attributes
        host_class = @system_arguments.delete(:class)
        merge_attributes(
          class: ["fp-grid__item", *Array(span_classes), host_class]
        )
      end

      def span_classes
        return if @span.nil?

        @span.map do |breakpoint, count|
          name = (count == :full) ? "col-span-full" : "col-span-#{count}"
          FlatPack::Shared::Breakpoints.utility(breakpoint, name)
        end
      end

      def normalize_span(span)
        return if span.nil?

        normalized = FlatPack::Shared::Breakpoints.normalize(span) { |count| normalize_span_count(count) }
        return normalized if span.is_a?(Hash) || !normalized.is_a?(Hash)

        count = normalized[:base]
        return {base: count} if count == :full || !count.is_a?(Integer)

        # A bare integer does not set base. An unprefixed col-span wider than
        # the one-column phone template adds an implicit auto track.
        {sm: count, md: count, lg: count, xl: count}
      end

      def normalize_span_count(count)
        return :full if count == :full || count.to_s == "full"
        return Integer(count) if count.is_a?(Integer) || integer_string?(count)

        count
      end

      def integer_string?(count)
        count.is_a?(String) && count.match?(/\A[+-]?\d+\z/)
      end

      def validate_span!
        return if @span.nil?

        unless @span.is_a?(Hash) && @span.any?
          raise ArgumentError, "Invalid span: #{@span.inspect}. Use an integer 1-12, :full, or a hash like {base: 1, md: 2, lg: 8}."
        end

        FlatPack::Shared::Breakpoints.validate_keys!(@span.keys, label: "span")

        @span.each do |breakpoint, count|
          unless count == :full || count.is_a?(Integer)
            raise ArgumentError, "Invalid span #{breakpoint}: #{count.inspect}. Must be an integer from 1 to 12, or :full."
          end

          next if count == :full || SPAN_COUNTS.cover?(count)

          raise ArgumentError, "Invalid span #{breakpoint}: #{count.inspect}. Must be an integer from 1 to 12, or :full."
        end
      end
    end
  end
end
