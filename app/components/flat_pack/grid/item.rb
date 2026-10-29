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
      BREAKPOINTS = %i[base sm md lg xl].freeze
      SPAN_COUNTS = (1..12)
      SPAN_CLASSES = {
        base: {
          1 => "col-span-1",
          2 => "col-span-2",
          3 => "col-span-3",
          4 => "col-span-4",
          5 => "col-span-5",
          6 => "col-span-6",
          7 => "col-span-7",
          8 => "col-span-8",
          9 => "col-span-9",
          10 => "col-span-10",
          11 => "col-span-11",
          12 => "col-span-12",
          :full => "col-span-full"
        },
        sm: {
          1 => "sm:col-span-1",
          2 => "sm:col-span-2",
          3 => "sm:col-span-3",
          4 => "sm:col-span-4",
          5 => "sm:col-span-5",
          6 => "sm:col-span-6",
          7 => "sm:col-span-7",
          8 => "sm:col-span-8",
          9 => "sm:col-span-9",
          10 => "sm:col-span-10",
          11 => "sm:col-span-11",
          12 => "sm:col-span-12",
          :full => "sm:col-span-full"
        },
        md: {
          1 => "md:col-span-1",
          2 => "md:col-span-2",
          3 => "md:col-span-3",
          4 => "md:col-span-4",
          5 => "md:col-span-5",
          6 => "md:col-span-6",
          7 => "md:col-span-7",
          8 => "md:col-span-8",
          9 => "md:col-span-9",
          10 => "md:col-span-10",
          11 => "md:col-span-11",
          12 => "md:col-span-12",
          :full => "md:col-span-full"
        },
        lg: {
          1 => "lg:col-span-1",
          2 => "lg:col-span-2",
          3 => "lg:col-span-3",
          4 => "lg:col-span-4",
          5 => "lg:col-span-5",
          6 => "lg:col-span-6",
          7 => "lg:col-span-7",
          8 => "lg:col-span-8",
          9 => "lg:col-span-9",
          10 => "lg:col-span-10",
          11 => "lg:col-span-11",
          12 => "lg:col-span-12",
          :full => "lg:col-span-full"
        },
        xl: {
          1 => "xl:col-span-1",
          2 => "xl:col-span-2",
          3 => "xl:col-span-3",
          4 => "xl:col-span-4",
          5 => "xl:col-span-5",
          6 => "xl:col-span-6",
          7 => "xl:col-span-7",
          8 => "xl:col-span-8",
          9 => "xl:col-span-9",
          10 => "xl:col-span-10",
          11 => "xl:col-span-11",
          12 => "xl:col-span-12",
          :full => "xl:col-span-full"
        }
      }.freeze

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
        merge_attributes(
          class: span_classes
        )
      end

      def span_classes
        return if @span.nil?

        @span.map { |breakpoint, count| SPAN_CLASSES.fetch(breakpoint).fetch(count) }
      end

      def normalize_span(span)
        return if span.nil?

        if span.is_a?(Hash)
          span.to_h { |breakpoint, count| [breakpoint.to_sym, normalize_span_count(count)] }
        else
          {base: normalize_span_count(span)}
        end
      rescue ArgumentError, TypeError
        span
      end

      def normalize_span_count(count)
        return :full if count.to_s == "full"

        Integer(count)
      end

      def validate_span!
        return if @span.nil?

        unless @span.is_a?(Hash) && @span.any?
          raise ArgumentError, "Invalid span: #{@span.inspect}. Use an integer 1-12, :full, or a hash like {base: 1, md: 2, lg: 8}."
        end

        unknown = @span.keys - BREAKPOINTS
        if unknown.any?
          raise ArgumentError, "Invalid span breakpoints: #{unknown.join(", ")}. Must be one of: #{BREAKPOINTS.join(", ")}"
        end

        @span.each do |breakpoint, count|
          next if count == :full || SPAN_COUNTS.cover?(count)

          raise ArgumentError, "Invalid span #{breakpoint}: #{count.inspect}. Must be an integer from 1 to 12, or :full."
        end
      end
    end
  end
end
