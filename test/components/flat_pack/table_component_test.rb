# frozen_string_literal: true

require "test_helper"
require "ostruct"

module FlatPack
  module Table
    class ComponentTest < ViewComponent::TestCase
      def setup
        @users = [
          OpenStruct.new(id: 1, name: "Alice", email: "alice@example.com"),
          OpenStruct.new(id: 2, name: "Bob", email: "bob@example.com")
        ]
      end

      def test_renders_empty_table
        render_inline(Component.new(rows: []))
        
        assert_selector "table"
        assert_text "No data available"
      end

      def test_renders_table_with_columns
        render_inline(Component.new(rows: @users)) do |component|
          component.with_column(label: "Name", attribute: :name)
          component.with_column(label: "Email", attribute: :email)
        end
        
        assert_selector "table"
        assert_selector "th", text: "Name"
        assert_selector "th", text: "Email"
        assert_selector "td", text: "Alice"
        assert_selector "td", text: "alice@example.com"
      end

      def test_renders_table_with_block_columns
        render_inline(Component.new(rows: @users)) do |component|
          component.with_column(label: "Name") { |user| user.name.upcase }
        end
        
        assert_selector "td", text: "ALICE"
        assert_selector "td", text: "BOB"
      end

      def test_renders_table_with_actions
        render_inline(Component.new(rows: @users)) do |component|
          component.with_column(label: "Name", attribute: :name)
          component.with_action(label: "Edit", url: ->(user) { "/users/#{user.id}/edit" })
        end
        
        assert_selector "th", text: "Actions"
        assert_selector "a[href='/users/1/edit']", text: "Edit"
        assert_selector "a[href='/users/2/edit']", text: "Edit"
      end

      def test_renders_table_with_stimulus_controller
        render_inline(Component.new(rows: @users, stimulus: true)) do |component|
          component.with_column(label: "Name", attribute: :name)
        end
        
        assert_selector "div[data-controller='flat-pack--table']"
      end

      def test_renders_custom_action_block
        render_inline(Component.new(rows: @users)) do |component|
          component.with_column(label: "Name", attribute: :name)
          component.with_action do |user|
            tag.span("Custom #{user.name}", class: "custom-action")
          end
        end
        
        assert_selector "span.custom-action", text: "Custom Alice"
      end

      def test_merges_custom_classes
        render_inline(Component.new(rows: @users, class: "custom-table"))
        
        assert_selector "div.custom-table"
      end

      def test_empty_state_spans_all_columns
        render_inline(Component.new(rows: [])) do |component|
          component.with_column(label: "Name")
          component.with_column(label: "Email")
          component.with_action(label: "Edit")
        end
        
        assert_selector "td[colspan='3']", text: "No data available"
      end
    end
  end
end
