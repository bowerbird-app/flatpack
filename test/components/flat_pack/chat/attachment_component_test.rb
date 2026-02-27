# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module Attachment
      class ComponentTest < ViewComponent::TestCase
        def test_renders_file_attachment_with_content_width_classes
          render_inline(Component.new(name: "project-plan.pdf", meta: "840 KB"))

          assert_selector "div.inline-flex.w-fit.max-w-full.items-center.gap-3"
        end

        def test_renders_link_wrapper_as_inline_block
          render_inline(Component.new(name: "project-plan.pdf", href: "#"))

          assert_selector "a.inline-block.max-w-full.align-top"
        end

        def test_applies_filename_truncation_classes
          render_inline(Component.new(name: "very-long-file-name-that-should-be-truncated-when-space-is-limited.pdf"))

          assert_includes rendered_content, "truncate max-w-[32ch]"
          assert_text "very-long-file-name-that-should-be-truncated-when-space-is-limited.pdf"
        end

        def test_applies_meta_truncation_classes_when_meta_present
          render_inline(Component.new(name: "report.pdf", meta: "This is very long metadata text that should also be truncated"))

          assert_includes rendered_content, "text-xs text-[var(--chat-attachment-meta-color)] truncate max-w-[32ch]"
        end
      end
    end
  end
end
