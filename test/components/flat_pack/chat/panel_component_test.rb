# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module Panel
      class ComponentTest < ViewComponent::TestCase
        def test_renders_header_messages_and_composer_slots
          render_inline(Component.new) do |panel|
            panel.header { "Header" }
            panel.messages { "Messages" }
            panel.composer { "Composer" }
          end

          assert_text "Header"
          assert_text "Messages"
          assert_text "Composer"
        end

        def test_does_not_expose_with_prefixed_slot_setters
          component = Component.new

          refute_respond_to component, :with_header
          refute_respond_to component, :with_right_header
          refute_respond_to component, :with_right_header_content
          refute_respond_to component, :with_messages
          refute_respond_to component, :with_composer
        end

        def test_omitting_right_header_keeps_todays_markup
          render_inline(Component.new) do |panel|
            panel.header { "Header" }
            panel.messages { "Messages" }
            panel.composer { "Composer" }
          end

          assert_equal(
            %(<div class="flex flex-col h-full min-h-0 overflow-hidden"><div class="flex-shrink-0 border-b border-[var(--chat-header-border-color)] bg-[var(--chat-header-background-color)]">Header</div>MessagesComposer</div>),
            rendered_content
          )
          assert_no_selector "[data-flat-pack-chat-panel-part]"
        end

        def test_right_header_row_classes_and_order
          render_inline(Component.new) do |panel|
            panel.header { "Header" }
            panel.right_header { "Actions" }
          end

          wrapper = page.native.at_css("div.border-b")
          parts = wrapper.element_children

          assert_equal(
            "flex flex-shrink-0 border-b border-[var(--chat-header-border-color)] bg-[var(--chat-header-background-color)]",
            wrapper["class"]
          )
          assert_equal 2, parts.length
          assert_equal "header", parts[0]["data-flat-pack-chat-panel-part"]
          assert_equal "min-w-0 flex-1", parts[0]["class"]
          assert_equal "Header", parts[0].text
          assert_equal "right-header", parts[1]["data-flat-pack-chat-panel-part"]
          assert_equal "flex shrink-0 w-min items-center justify-end", parts[1]["class"]
          assert_equal "Actions", parts[1].text
          assert_operator rendered_content.index("Header"), :<, rendered_content.index("Actions")
        end

        def test_right_header_predicate_without_with_setter
          component = Component.new

          refute_respond_to component, :with_right_header
          refute_predicate component, :right_header?

          component.right_header { "Actions" }

          assert_predicate component, :right_header?
          assert_kind_of ViewComponent::Slot, component.right_header
        end

        def test_merges_custom_class_with_right_header
          render_inline(Component.new(class: "custom-panel gap-4")) do |panel|
            panel.header { "Header" }
            panel.right_header { "Actions" }
          end

          root = page.native.at_css("div.custom-panel")
          header = page.native.at_css("[data-flat-pack-chat-panel-part='header']")
          actions = page.native.at_css("[data-flat-pack-chat-panel-part='right-header']")

          assert_equal "custom-panel gap-4 flex flex-col h-full min-h-0 overflow-hidden", root["class"]
          refute_includes header["class"], "custom-panel"
          refute_includes header["class"], "gap-4"
          assert_equal "min-w-0 flex-1", header["class"]
          assert_equal "flex shrink-0 w-min items-center justify-end", actions["class"]
        end

        def test_right_header_alone_renders_the_row
          render_inline(Component.new) do |panel|
            panel.right_header { "Actions" }
          end

          wrapper = page.native.at_css("div.border-b")
          parts = wrapper.element_children

          assert_includes wrapper["class"], "flex"
          assert_includes wrapper["class"], "border-b"
          assert_includes wrapper["class"], "bg-[var(--chat-header-background-color)]"
          assert_equal 1, parts.length
          assert_equal "right-header", parts[0]["data-flat-pack-chat-panel-part"]
          assert_equal "ml-auto flex shrink-0 w-min items-center justify-end", parts[0]["class"]
          assert_includes parts[0]["class"], "ml-auto"
          assert_equal "Actions", parts[0].text
          assert_no_selector "[data-flat-pack-chat-panel-part='header']"
        end

        def test_right_header_alone_is_right_aligned
          render_inline(Component.new) do |panel|
            panel.right_header { "Actions" }
          end

          actions = page.native.at_css("[data-flat-pack-chat-panel-part='right-header']")

          assert_includes actions["class"], "ml-auto"
          assert_includes actions["class"], "justify-end"
          assert_includes actions["class"], "w-min"
        end

        def test_applies_header_container_styles
          render_inline(Component.new) do |panel|
            panel.header { "Header" }
          end

          assert_selector "div.border-b"
          assert_includes page.native.to_html, "border-[var(--chat-header-border-color)]"
        end

        def test_merges_custom_class
          render_inline(Component.new(class: "custom-panel"))

          assert_selector "div.custom-panel"
        end
      end
    end
  end
end
