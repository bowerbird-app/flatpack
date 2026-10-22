# frozen_string_literal: true

module FlatPack
  # Page nav items for one request, in the order they were registered, per bucket.
  # Data only. It does not render, place, or style. Hold an instance on the
  # request. Do not keep one on the class.
  #
  # This is not FlatPack::PageNav, the back and close row.
  class PageNavRegistry
    DEFAULT_BUCKET = :default

    def initialize
      @buckets = {}
    end

    def add(item, into: DEFAULT_BUCKET)
      (@buckets[normalize_bucket!(into)] ||= []) << item
      nil
    end

    # Descriptors for one bucket, in registration order. A missing bucket is empty.
    def items(from: DEFAULT_BUCKET)
      list = @buckets[normalize_bucket!(from)]
      list ? list.dup : []
    end

    def empty?(from = nil)
      if from.nil?
        @buckets.each_value.all?(&:empty?)
      else
        items(from: from).empty?
      end
    end

    private

    def normalize_bucket!(name)
      if name.nil? || (name.respond_to?(:empty?) && name.empty?)
        raise ArgumentError, "page nav bucket needs a name"
      end
      unless name.is_a?(Symbol) || name.is_a?(String)
        raise ArgumentError, "page nav bucket must be a name"
      end

      symbol = name.to_sym
      raise ArgumentError, "page nav bucket needs a name" if symbol.name.empty?

      symbol
    end
  end
end
