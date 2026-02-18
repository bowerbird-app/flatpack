# frozen_string_literal: true

require "test_helper"

module FlatPack
  module TopNav
    module Search
      class ComponentTest < ViewComponent::TestCase
        def test_renders_via_compatibility_wrapper
          render_inline(Component.new(
            placeholder: "Search docs...",
            search_url: "/demo/search_results"
          ))

          assert_selector "input[type='text'][name='q'][placeholder='Search docs...']"
          assert_selector "div[data-controller='flat-pack--search']"
          assert_includes page.native.to_html, "#icon-search"
        end
      end
    end
  end
end
