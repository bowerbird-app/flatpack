# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Billing
    module PlanPicker
      class ComponentTest < ViewComponent::TestCase
        def test_renders_plan_cards
          render_inline(Component.new(items: [
            {name: "Basic", price_text: "$9 / month", features: ["3 seats"], href: "/plans/basic"},
            {name: "Pro", price_text: "$29 / month", current: true, highlighted: true, cta_text: "Current plan"}
          ]))

          assert_text "Basic"
          assert_text "Pro"
          assert_text "Popular"
          assert_text "Current"
          assert_text "Current plan"
          assert_text "3 seats"
        end

        def test_requires_item_name
          assert_raises(ArgumentError) { Component.new(items: [{price_text: "$9"}]) }
        end

        def test_rejects_unsafe_href
          assert_raises(ArgumentError) do
            Component.new(items: [{name: "Pro", href: "javascript:alert(1)"}])
          end
        end

        def test_href_cta_stays_a_link
          render_inline(Component.new(items: [
            {name: "Basic", href: "/plans/basic", cta_text: "Choose Basic"}
          ]))

          assert_selector "a[href='/plans/basic']", text: "Choose Basic"
          assert_no_selector "form"
        end

        def test_url_cta_submits_a_form
          render_inline(Component.new(items: [
            {
              name: "Pro",
              url: "/billing/plans/pro",
              method: :patch,
              params: {plan: "pro", seats: 10},
              turbo: false,
              cta_text: "Switch to Pro"
            }
          ]))

          assert_selector "form.contents[action='/billing/plans/pro'][method='post'][data-turbo='false']"
          assert_selector "form input[name='_method'][value='patch']", visible: :hidden
          assert_selector "form input[name='plan'][value='pro']", visible: :hidden
          assert_selector "form input[name='seats'][value='10']", visible: :hidden
          assert_selector "form button[type='submit']", text: "Switch to Pro"
          assert_no_selector "a", text: "Switch to Pro"
        end

        def test_url_cta_defaults_to_post
          render_inline(Component.new(items: [
            {name: "Basic", url: "/billing/plans/basic", cta_text: "Subscribe"}
          ]))

          assert_selector "form.contents[action='/billing/plans/basic'][method='post'][data-turbo='true']"
          assert_no_selector "form input[name='_method']", visible: :all
        end

        def test_rejects_href_and_url_together
          error = assert_raises(ArgumentError) do
            Component.new(items: [{name: "Pro", href: "/plans/pro", url: "/billing/plans/pro"}])
          end

          assert_match(/href: or url:/, error.message)
        end

        def test_rejects_unsafe_url_and_bad_form_options
          assert_raises(ArgumentError) do
            Component.new(items: [{name: "Pro", url: "javascript:alert(1)"}])
          end

          error = assert_raises(ArgumentError) do
            Component.new(items: [{name: "Pro", url: "/plans/pro", method: :head}])
          end
          assert_match(/method:/, error.message)

          error = assert_raises(ArgumentError) do
            Component.new(items: [{name: "Pro", href: "/plans/pro", params: {plan: "pro"}}])
          end
          assert_match(/params: needs url:/, error.message)

          error = assert_raises(ArgumentError) do
            Component.new(items: [{name: "Pro", url: "/plans/pro", turbo: "yes"}])
          end
          assert_match(/turbo:/, error.message)
        end

        def test_plan_footer_replaces_that_plans_cta
          render_inline(Component.new(items: [
            {name: "Basic", href: "/plans/basic", cta_text: "Choose Basic"},
            {name: "Enterprise", href: "/contact", cta_text: "Contact sales"}
          ])) do |picker|
            picker.plan_footer(name: "Enterprise") { "<a href=\"/book\">Book a call</a>".html_safe }
          end

          assert_selector "a[href='/plans/basic']", text: "Choose Basic"
          assert_selector "a[href='/book']", text: "Book a call"
          assert_no_selector "a[href='/contact']"
          assert_no_text "Contact sales"
        end

        def test_plan_footer_rejects_an_unknown_or_duplicate_name
          error = assert_raises(ArgumentError) do
            render_inline(Component.new(items: [{name: "Pro"}])) do |picker|
              picker.plan_footer(name: "Nope") { "Missing" }
            end
          end
          assert_match(/Unknown plan_footer name/, error.message)

          error = assert_raises(ArgumentError) do
            render_inline(Component.new(items: [{name: "Pro"}])) do |picker|
              picker.plan_footer(name: "Pro") { "Once" }
              picker.plan_footer(name: "Pro") { "Twice" }
            end
          end
          assert_match(/already set/, error.message)
        end

        def test_cols_sets_desktop_columns_and_defaults_to_three
          render_inline(Component.new(items: [{name: "Solo"}]))

          assert_includes rendered_content, "grid-cols-1"
          assert_includes rendered_content, "md:grid-cols-2"
          assert_includes rendered_content, "lg:grid-cols-3"

          render_inline(Component.new(cols: 4, items: [{name: "Solo"}]))

          assert_includes rendered_content, "lg:grid-cols-4"
          refute_includes rendered_content, "lg:grid-cols-3"

          render_inline(Component.new(cols: 2, items: [{name: "Solo"}]))

          assert_includes rendered_content, "md:grid-cols-2"
          refute_includes rendered_content, "lg:grid-cols-"
        end

        def test_rejects_unknown_cols
          error = assert_raises(ArgumentError) { Component.new(cols: 5, items: [{name: "Pro"}]) }

          assert_match(/cols:/, error.message)
        end

        def test_padding_uses_the_card_scale
          render_inline(Component.new(padding: :lg, items: [{name: "Pro", href: "/plans/pro"}]))

          assert_selector "[data-fp-card-padding='lg']"
          assert_includes rendered_content, "p-[var(--card-padding-lg)]"
          refute_includes rendered_content, "p-[var(--card-padding-md)]"

          render_inline(Component.new(padding: :sm, items: [{name: "Pro"}]))

          assert_selector "[data-fp-card-padding='sm']"
          assert_includes rendered_content, "p-[var(--card-padding-sm)]"
        end

        def test_rejects_unknown_padding
          error = assert_raises(ArgumentError) { Component.new(padding: :xl, items: [{name: "Pro"}]) }

          assert_match(/padding:/, error.message)
        end
      end
    end
  end
end
