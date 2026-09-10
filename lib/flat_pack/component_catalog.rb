# frozen_string_literal: true

module FlatPack
  # Inventory of public FlatPack ViewComponents for hosts (Recording Studio API / MCP).
  class ComponentCatalog
    class << self
      def list
        records = entries.map { |entry| skinny(entry) }
        {
          records: records,
          meta: {
            count: records.size,
            gem_version: FlatPack::VERSION,
            publicity: {
              scope: "public",
              excludes: publicity_excludes
            }
          }
        }
      end

      def show(name)
        entry = find_entry(name)
        return if entry.nil?

        skinny(entry).merge(
          parameters: parameters_for(entry[:class_object]),
          slots: slots_for(entry[:class_object])
        )
      end

      def reset!
        @entries = nil
      end

      private

      def entries
        @entries ||= build_entries
      end

      def skinny(entry)
        entry.slice(:name, :class, :description, :category)
      end

      def build_entries
        raise "stub"
      end
    end
  end
end
