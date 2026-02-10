# frozen_string_literal: true

module FlatPack
  module Navbar
    class NavSectionComponent < ViewComponent::Base
      renders_many :items, NavItemComponent

      # Alias for shorter syntax (optional - both work)
      def item(**kwargs, &block)
        with_item(**kwargs, &block)
      end

      def initialize(
        title: nil,
        collapsible: false,
        collapsed: false,
        **system_arguments
      )
        @title = title
        @collapsible = collapsible
        @collapsed = collapsed
        @system_arguments = system_arguments
      end

      private

      def section_attributes
        {
          class: section_classes
        }.merge(@system_arguments)
      end

      def section_classes
        classes(
          "flatpack-navbar-section",
          "space-y-1"
        )
      end

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
