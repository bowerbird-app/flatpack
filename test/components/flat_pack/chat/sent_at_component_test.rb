# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module SentAt
      class ComponentTest < ViewComponent::TestCase
        def test_renders_sent_copy_from_i18n
          render_inline(Component.new(timestamp: Time.zone.parse("2026-11-10 14:30:00")))

          assert_text "Sent 2:30 PM"
          refute_includes rendered_content, "display:none"
          refute_includes rendered_content, "visibility:hidden"
          refute_includes rendered_content, "aria-hidden"
        end

        def test_renders_string_timestamp
          render_inline(Component.new(timestamp: "2:30 PM"))

          assert_text "Sent 2:30 PM"
        end
      end
    end
  end
end
