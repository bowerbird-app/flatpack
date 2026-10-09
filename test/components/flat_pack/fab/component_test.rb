# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Fab
    class ComponentTest < ViewComponent::TestCase
      def test_single_action_renders_a_button
        render_inline(Component.new(label: "Add"))

        assert_selector "div.fp-fab.fp-fab--viewport[data-fp-position='bottom_right']"
        assert_selector "button.fp-fab__trigger[aria-label='Add'][type='button']"
        refute_selector "[data-controller='flat-pack--fab']"
        refute_selector "[role='menu']"
        refute_selector ".fp-fab__backdrop"
      end

      def test_single_action_link_uses_href
        render_inline(Component.new(href: "/notes/new", label: "New note", icon: :pencil))

        assert_selector "a.fp-fab__trigger[href='/notes/new'][aria-label='New note']"
        assert_selector ".fp-fab__text", text: "New note"
        assert_selector ".fp-fab__trigger--extended"
      end

      def test_single_action_merges_data_onto_the_control
        render_inline(Component.new(label: "Save", data: {turbo_method: "post", testid: "compose"}))

        assert_selector "button.fp-fab__trigger[data-turbo-method='post'][data-testid='compose']"
        refute_selector "div.fp-fab[data-turbo-method]"
      end

      def test_speed_dial_renders_menu_semantics
        render_inline(Component.new) do |fab|
          fab.with_action(icon: :pencil, label: "Note", href: "/notes/new")
          fab.with_action(icon: :camera, label: "Photo")
        end

        assert_selector "[data-controller='flat-pack--fab']"
        assert_selector "button.fp-fab__trigger[aria-expanded='false'][aria-haspopup='menu']"
        assert_selector "ul.fp-fab__actions[role='menu'][hidden]"
        assert_selector "[role='menuitem'][aria-label='Note'][href='/notes/new']", count: 1
        assert_selector "button[role='menuitem'][aria-label='Photo']"
        trigger = page.find("button.fp-fab__trigger")
        menu_id = trigger["aria-controls"]

        assert menu_id.present?
        assert_selector "ul##{menu_id}[role='menu']"
      end

      def test_speed_dial_system_arguments_land_on_root
        render_inline(Component.new(class: "host-fab", data: {testid: "speed"})) do |fab|
          fab.with_action(icon: :pencil, label: "Note")
        end

        assert_selector "div.fp-fab.host-fab[data-testid='speed']"
        refute_selector "button.fp-fab__trigger[data-testid]"
      end

      def test_speed_dial_action_keeps_host_data
        render_inline(Component.new) do |fab|
          fab.with_action(
            icon: :user_plus,
            label: "Invite",
            data: {modal_id: "invite", testid: "invite-action"}
          )
        end

        assert_selector "[role='menuitem'][data-modal-id='invite'][data-testid='invite-action']"
        assert_includes page.native.to_html, "click->flat-pack--fab#choose"
      end

      def test_positions_and_sizes
        render_inline(Component.new(position: :top_left, size: :lg, label: "Add"))

        assert_selector "[data-fp-position='top_left'][data-fp-size='lg']"
      end

      def test_layout_stack_is_the_default
        render_inline(Component.new(label: "Add"))

        assert_selector "[data-fp-fab-layout='stack']"
      end

      def test_rejects_arc_layout
        error = assert_raises(ArgumentError) { Component.new(layout: :arc) }

        assert_includes error.message, "Invalid layout: arc"
        assert_includes error.message, "later release"
      end

      def test_rejects_unknown_position
        error = assert_raises(ArgumentError) { Component.new(position: :center) }

        assert_includes error.message, "Invalid position: center"
      end

      def test_rejects_unknown_size
        error = assert_raises(ArgumentError) { Component.new(size: :sm) }

        assert_includes error.message, "Invalid size: sm"
      end

      def test_rejects_invalid_offset
        error = assert_raises(ArgumentError) { Component.new(offset: "10") }

        assert_includes error.message, "Invalid offset"
      end

      def test_backdrop_can_be_disabled
        render_inline(Component.new(backdrop: false)) do |fab|
          fab.with_action(icon: :pencil, label: "Note")
        end

        refute_selector ".fp-fab__backdrop"
      end

      def test_hide_on_scroll_wires_the_controller
        render_inline(Component.new(href: "/new", label: "Add", hide_on_scroll: true))

        assert_selector "[data-controller='flat-pack--fab']"
        assert_selector "[data-flat-pack--fab-hide-on-scroll-value='true']"
        assert_includes page.native.to_html, "scroll@window->flat-pack--fab#onScroll"
      end

      def test_contained_and_offset
        render_inline(Component.new(contained: true, offset: "1.5rem", label: "Add"))

        assert_selector "div.fp-fab--contained"
        assert_includes page.native.to_html, "--fp-fab-offset: 1.5rem"
      end

      def test_rejects_unsafe_href
        error = assert_raises(ArgumentError) { Component.new(href: "javascript:alert(1)", label: "Add") }

        assert_includes error.message, "Unsafe URL detected"
      end

      def test_action_rejects_unsafe_href
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |fab|
            fab.with_action(icon: :pencil, label: "Note", href: "javascript:alert(1)")
          end
        end

        assert_includes error.message, "Unsafe URL detected"
      end

      def test_action_requires_label
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |fab|
            fab.with_action(icon: :pencil, label: "")
          end
        end

        assert_includes error.message, "FAB actions need a label"
      end

      def test_default_accessible_name
        render_inline(Component.new)

        assert_selector "button.fp-fab__trigger[aria-label='Add']"
      end

      def test_speed_dial_default_accessible_name
        render_inline(Component.new) do |fab|
          fab.with_action(icon: :pencil, label: "Note")
        end

        assert_selector "button.fp-fab__trigger[aria-label='Open actions']"
        assert_selector "ul[role='menu'][aria-label='Actions']"
      end
    end
  end
end
