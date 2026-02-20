# frozen_string_literal: true

module FlatPack
  module PageTitle
    class Component < FlatPack::PageHeader::Component
      private

      def container_classes
        classes("pb-8", "mb-6")
      end
    end
  end
end
