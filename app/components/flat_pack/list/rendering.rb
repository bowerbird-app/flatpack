# frozen_string_literal: true

module FlatPack
  module List
    # Tracks the list that is rendering its block so items can match that layout.
    # Items must be rendered inside the list block. A row built beforehand cannot
    # see the layout and stays an ordinary list item.
    module Rendering
      THREAD_KEY = :flat_pack_list_rendering

      class << self
        def with(layout:, stack_below: nil, align: :start)
          previous = Thread.current[THREAD_KEY]
          Thread.current[THREAD_KEY] = {layout: layout, stack_below: stack_below, align: align}
          yield
        ensure
          Thread.current[THREAD_KEY] = previous
        end

        def layout
          current.fetch(:layout)
        end

        def stack_below
          current.fetch(:stack_below)
        end

        def align
          current.fetch(:align)
        end

        def key_value?
          layout == :key_value
        end

        private

        def current
          Thread.current[THREAD_KEY] || {layout: :items, stack_below: nil, align: :start}
        end
      end
    end
  end
end
