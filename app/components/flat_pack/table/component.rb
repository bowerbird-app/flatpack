# frozen_string_literal: true

module FlatPack
  module Table
    class Component < FlatPack::BaseComponent
      renders_many :columns, ColumnComponent
      renders_many :actions, ActionComponent

      def initialize(rows: [], stimulus: false, **system_arguments)
        super(**system_arguments)
        @rows = rows
        @stimulus = stimulus
      end

      def call
        tag.div(**container_attributes) do
          tag.table(**table_attributes) do
            safe_join([render_header, render_body])
          end
        end
      end

      private

      def container_attributes
        attrs = merge_attributes(
          class: "overflow-x-auto rounded-[var(--radius-lg)] border border-[var(--color-border)]"
        )
        
        if @stimulus
          attrs[:data] ||= {}
          attrs[:data][:controller] = "flat-pack--table"
        end
        
        attrs
      end

      def table_attributes
        {
          class: classes(
            "w-full",
            "border-collapse",
            "bg-[var(--color-background)]"
          )
        }
      end

      def render_header
        return unless columns.any?

        tag.thead class: "bg-[var(--color-muted)]" do
          tag.tr do
            safe_join([
              columns.map { |column| column.render_header },
              (tag.th("Actions", class: header_cell_classes) if actions.any?)
            ].flatten.compact)
          end
        end
      end

      def render_body
        tag.tbody class: "divide-y divide-[var(--color-border)]" do
          if @rows.any?
            safe_join(@rows.map { |row| render_row(row) })
          else
            render_empty_state
          end
        end
      end

      def render_row(row)
        tag.tr class: "hover:bg-[var(--color-muted)] transition-colors duration-[var(--transition-fast)]" do
          safe_join([
            columns.map { |column| column.render_cell(row) },
            (render_actions_cell(row) if actions.any?)
          ].flatten.compact)
        end
      end

      def render_actions_cell(row)
        tag.td class: body_cell_classes do
          tag.div class: "flex items-center gap-2" do
            safe_join(actions.map { |action| 
              result = action.render_action(row)
              # If it's a component, render it; otherwise return it directly
              result.is_a?(ViewComponent::Base) ? render(result) : result
            })
          end
        end
      end

      def render_empty_state
        tag.tr do
          tag.td colspan: column_count, class: "#{body_cell_classes} text-center text-[var(--color-muted-foreground)]" do
            "No data available"
          end
        end
      end

      def header_cell_classes
        "px-4 py-3 text-left text-xs font-medium text-[var(--color-muted-foreground)] uppercase tracking-wider"
      end

      def body_cell_classes
        "px-4 py-3 text-sm text-[var(--color-foreground)]"
      end

      def column_count
        columns.size + (actions.any? ? 1 : 0)
      end
    end
  end
end
