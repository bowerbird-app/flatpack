# frozen_string_literal: true

module FlatPack
  module Navbar
    class Component < FlatPack::BaseComponent
      renders_one :top_nav, FlatPack::Navbar::TopNavComponent
      renders_one :left_nav, FlatPack::Navbar::LeftNavComponent
      renders_one :content

      def initialize(**system_arguments)
        super(**system_arguments)
      end

      def call
        tag.div(**wrapper_attributes) do
          safe_join([top_nav, left_nav, main_content])
        end
      end

      private

      def wrapper_attributes
        merge_attributes(
          class: "flat-pack-navbar flex flex-col h-screen overflow-hidden",
          data: {
            controller: "flat-pack--navbar"
          }
        )
      end

      def main_content
        return unless content

        tag.main(
          class: "flex-1 overflow-auto transition-all duration-300 ease-in-out bg-[var(--color-background)]",
          data: {
            flat_pack__navbar_target: "content"
          }
        ) do
          content
        end
      end
    end
  end
end
