# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Card
    class ComponentTest < ViewComponent::TestCase
      # Basic Card Tests
      def test_renders_basic_card
        render_inline(Component.new)
        assert_selector "div"
      end

      def test_card_does_not_force_a_height
        render_inline(Component.new) { "Note" }

        classes = page.find(".fp-card")[:class].to_s.split
        refute_includes classes, "h-full"
      end

      def test_renders_card_with_content
        render_inline(Component.new) do
          "Card content"
        end
        assert_text "Card content"
      end

      # Style Tests
      def test_renders_with_style_default
        render_inline(Component.new(background: :default))
        html = page.native.to_html
        assert_includes html, "[background:var(--card-background-default)]"
        assert_includes html, "border-solid border-[length:var(--card-border-width)] border-[var(--card-border-color)]"
        assert_includes html, "shadow-[var(--card-shadow)]"
        assert_includes html, 'data-background="default"'
        refute_includes html, "shadow-[var(--shadow-md)]"
        refute_includes html, "border-2"
        refute_includes html, "fp-card-hover-"
        refute_includes html, "bg-[var(--card-background-color)]"
      end

      def test_renders_shaded_brand_and_gradient_styles
        render_inline(Component.new(background: :shaded))
        shaded = page.native.to_html
        assert_includes shaded, "[background:var(--card-background-shaded)]"
        assert_includes shaded, "[--surface-content-color:var(--card-background-shaded-text-color)]"
        assert_includes shaded, "[--surface-muted-content-color:var(--card-background-shaded-muted-text-color)]"
        assert_includes shaded, "[--card-border-color:var(--card-background-shaded-border-color)]"
        assert_includes shaded, 'data-background="shaded"'

        render_inline(Component.new(background: :brand, shadow: :md))
        brand = page.native.to_html
        assert_includes brand, "[background:var(--card-background-brand)]"
        assert_includes brand, "[--surface-content-color:var(--card-background-brand-text-color)]"
        assert_includes brand, "[--surface-border-color:var(--card-background-brand-border-color)]"
        assert_includes brand, "shadow-[var(--shadow-md)]"
        assert_includes brand, 'data-background="brand"'
        refute_includes brand, "bg-[var(--card-background-color)]"

        render_inline(Component.new(background: :gradient))
        gradient = page.native.to_html
        assert_includes gradient, "[background:var(--card-background-gradient)]"
        assert_includes gradient, 'data-background="gradient"'

        render_inline(Component.new(background: :brand_subtle, border: :strong))
        subtle = page.native.to_html
        assert_includes subtle, "[background:var(--card-background-brand-subtle)]"
        assert_includes subtle, "border-2"
        assert_includes subtle, 'data-background="brand_subtle"'
      end

      def test_shadow_and_border_are_independent_of_style
        render_inline(Component.new(shadow: :sm, border: :none))
        html = page.native.to_html
        assert_includes html, "shadow-[var(--shadow-sm)]"
        assert_includes html, "border-0"
        refute_includes html, "border border-[var(--card-border-color)]"
        refute_includes html, "border-[length:var(--card-border-width)]"
        refute_includes html, "border-2"
        refute_includes html, "shadow-[var(--card-shadow)]"
      end

      def test_explicit_shadow_and_border_override_theme_tokens
        render_inline(Component.new(shadow: :none, border: :default))
        html = page.native.to_html
        assert_includes html, "shadow-none"
        assert_includes html, "border border-[var(--card-border-color)]"
        refute_includes html, "shadow-[var(--card-shadow)]"
        refute_includes html, "border-[length:var(--card-border-width)]"

        render_inline(Component.new(shadow: :md, border: :strong))
        strong = page.native.to_html
        assert_includes strong, "shadow-[var(--shadow-md)]"
        assert_includes strong, "border-2"
        refute_includes strong, "shadow-[var(--card-shadow)]"
      end

      def test_renders_with_hover_subtle
        render_inline(Component.new(border: :strong, hover: :subtle))
        assert_includes page.native.to_html, "fp-card-hover-subtle"
      end

      def test_renders_with_hover_strong
        render_inline(Component.new(border: :strong, hover: :strong))
        assert_includes page.native.to_html, "fp-card-hover-strong"
      end

      def test_hover_defaults_to_none
        render_inline(Component.new)
        refute_includes page.native.to_html, "fp-card-hover-strong"
        refute_includes page.native.to_html, "fp-card-hover-subtle"
      end

      def test_rejects_removed_structural_styles
        %i[flat elevated outlined interactive list].each do |style|
          error = assert_raises(ArgumentError) do
            render_inline(Component.new(background: style))
          end
          assert_includes error.message, "Invalid background"
        end
      end

      def test_rejects_removed_style_keyword
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(style: :brand))
        end
        assert_includes error.message, "unknown keyword: :style"
      end

      def test_validates_background
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(background: :invalid))
        end
        assert_includes error.message, "Invalid background"
      end

      def test_none_background_is_transparent_and_inherits_text
        render_inline(Component.new(background: :none))
        html = page.native.to_html
        assert_includes html, "[background:var(--card-background-none)]"
        assert_includes html, 'data-background="none"'
        refute_includes html, "--surface-content-color:var(--card-background-none"
        refute_includes html, "--card-border-color:var(--card-background-none"
      end

      def test_validates_hover
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(hover: :invalid))
        end
        assert_includes error.message, "Invalid hover"
      end

      # Padding Tests
      def test_renders_with_padding_none
        render_inline(Component.new(padding: :none))
        refute_includes page.native.to_html, "p-4"
        refute_includes page.native.to_html, "p-6"
        refute_includes page.native.to_html, "p-8"
      end

      def test_renders_with_padding_sm
        render_inline(Component.new(padding: :sm))
        assert_includes page.native.to_html, "p-[var(--card-padding-sm)]"
      end

      def test_renders_with_padding_md
        render_inline(Component.new(padding: :md))
        assert_includes page.native.to_html, "p-[var(--card-padding-md)]"
      end

      def test_renders_with_padding_lg
        render_inline(Component.new(padding: :lg))
        assert_includes page.native.to_html, "p-[var(--card-padding-lg)]"
      end

      def test_rejects_removed_theme_option
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(theme: {background: "#101820"}))
        end
        assert_includes error.message, "unknown keyword"
        assert_includes error.message, "theme"
      end

      def test_keeps_caller_style_attribute
        render_inline(Component.new("style" => "background-color: transparent"))

        html = page.native.to_html
        assert_includes html, "background-color: transparent"
        assert_includes html, "[background:var(--card-background-default)]"
        refute_includes html, "--card-background-color:"
      end

      def test_rejects_unknown_tone_keyword
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(tone: :brand))
        end
        assert_includes error.message, "unknown keyword"
        assert_includes error.message, "tone"
      end

      def test_brand_style_rescopes_surface_tokens
        render_inline(Component.new(background: :brand)) do |card|
          card.footer do
            <<~HTML.html_safe
              <button class="bg-[var(--button-primary-background-color)] text-[var(--button-primary-text-color)]">
                Pay now
              </button>
            HTML
          end
        end

        html = page.native.to_html
        assert_includes html, "[--surface-content-color:var(--card-background-brand-text-color)]"
        assert_includes html, "[--surface-muted-content-color:var(--card-background-brand-muted-text-color)]"
        assert_includes html, "[--surface-border-color:var(--card-background-brand-border-color)]"
        assert_includes html, "bg-[var(--button-primary-background-color)]"
        refute_includes html, "#101820"
      end

      def test_validates_padding
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(padding: :invalid))
        end
        assert_includes error.message, "Invalid padding"
      end

      # Clickable Card Tests
      def test_renders_clickable_card_with_href
        render_inline(Component.new(clickable: true, href: "/posts/1")) do
          "Clickable card"
        end
        assert_selector "a[href='/posts/1']", text: "Clickable card"
      end

      def test_clickable_card_wraps_in_link
        render_inline(Component.new(clickable: true, href: "/posts/1"))
        assert_selector "a"
      end

      def test_non_clickable_card_renders_as_div
        render_inline(Component.new(clickable: false))
        assert_selector "div"
        assert_no_selector "a"
      end

      def test_clickable_without_href_renders_as_div
        render_inline(Component.new(clickable: true))
        assert_selector "div"
        assert_no_selector "a"
      end

      def test_validates_href_url_safety
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(clickable: true, href: "javascript:alert('XSS')"))
        end
        assert_includes error.message, "Unsafe URL"
      end

      # Slot Tests
      def test_renders_with_header_slot
        render_inline(Component.new) do |component|
          component.header do
            "<h3>Card Title</h3>".html_safe
          end
        end
        assert_selector "h3", text: "Card Title"
      end

      def test_renders_with_body_slot
        render_inline(Component.new) do |component|
          component.body do
            "<p>Card body content</p>".html_safe
          end
        end
        assert_selector "p", text: "Card body content"
      end

      def test_renders_with_footer_slot
        render_inline(Component.new) do |component|
          component.footer do
            "<button>Action</button>".html_safe
          end
        end
        assert_selector "button", text: "Action"
      end

      def test_renders_with_media_slot
        render_inline(Component.new) do |component|
          component.media do
            "<img src='test.jpg' alt='Test'>".html_safe
          end
        end
        assert_selector "img[src='test.jpg']"
      end

      def test_renders_with_all_slots
        render_inline(Component.new) do |component|
          component.media { "<img src='test.jpg'>".html_safe }
          component.header { "<h3>Title</h3>".html_safe }
          component.body { "<p>Content</p>".html_safe }
          component.footer { "<button>Action</button>".html_safe }
        end
        assert_selector "img"
        assert_selector "h3", text: "Title"
        assert_selector "p", text: "Content"
        assert_selector "button", text: "Action"
      end

      def test_empty_card_without_slots
        render_inline(Component.new)
        assert_selector "div"
      end

      # Header Component Tests
      def test_header_component_renders
        render_inline(Header::Component.new) { "Header content" }
        assert_selector "div", text: "Header content"
      end

      def test_header_with_divider
        render_inline(Header::Component.new(divider: true)) { "Header" }
        assert_includes page.native.to_html, "border-b"
        assert_includes page.native.to_html, "border-[var(--card-border-color)]"
      end

      def test_header_without_divider
        render_inline(Header::Component.new(divider: false)) { "Header" }
        refute_includes page.native.to_html, "border-b"
      end

      def test_header_default_divider_is_true
        render_inline(Header::Component.new) { "Header" }
        assert_includes page.native.to_html, "border-b"
      end

      def test_header_has_padding_classes
        render_inline(Header::Component.new) { "Header" }
        assert_includes page.native.to_html, "p-[var(--card-padding-md)]"
      end

      def test_header_merges_custom_classes_with_defaults
        render_inline(Header::Component.new(class: "custom-header", divider: true)) { "Header" }
        html = page.native.to_html
        assert_includes html, "custom-header"
        assert_includes html, "p-[var(--card-padding-md)]"
        assert_includes html, "border-b"
      end

      # Body Component Tests
      def test_body_component_renders
        render_inline(Body::Component.new) { "Body content" }
        assert_selector "div", text: "Body content"
      end

      def test_body_has_padding_classes
        render_inline(Body::Component.new) { "Body" }
        assert_includes page.native.to_html, "p-[var(--card-padding-md)]"
      end

      def test_body_allows_padding_none
        render_inline(Body::Component.new(padding: :none, class: "px-3 py-2")) { "Body" }

        html = page.native.to_html
        refute_includes html, "p-[var(--card-padding-md)]"
        assert_includes html, "px-3"
        assert_includes html, "py-2"
      end

      def test_body_merges_custom_classes_with_defaults
        render_inline(Body::Component.new(class: "space-y-4")) { "Body" }
        html = page.native.to_html
        assert_includes html, "space-y-4"
        assert_includes html, "p-[var(--card-padding-md)]"
        assert_includes html, "flex-1"
      end

      # Footer Component Tests
      def test_footer_component_renders
        render_inline(Footer::Component.new) { "Footer content" }
        assert_selector "div", text: "Footer content"
      end

      def test_footer_with_divider
        render_inline(Footer::Component.new(divider: true)) { "Footer" }
        assert_includes page.native.to_html, "border-t"
        assert_includes page.native.to_html, "border-[var(--card-border-color)]"
      end

      def test_footer_without_divider
        render_inline(Footer::Component.new(divider: false)) { "Footer" }
        refute_includes page.native.to_html, "border-t"
      end

      def test_footer_default_divider_is_true
        render_inline(Footer::Component.new) { "Footer" }
        assert_includes page.native.to_html, "border-t"
      end

      def test_footer_has_padding_classes
        render_inline(Footer::Component.new) { "Footer" }
        assert_includes page.native.to_html, "p-[var(--card-padding-md)]"
      end

      def test_footer_merges_custom_classes_with_defaults
        render_inline(Footer::Component.new(class: "custom-footer", divider: true)) { "Footer" }
        html = page.native.to_html
        assert_includes html, "custom-footer"
        assert_includes html, "p-[var(--card-padding-md)]"
        assert_includes html, "border-t"
      end

      # Media Component Tests
      def test_media_component_renders
        render_inline(Media::Component.new) { "<img src='test.jpg'>".html_safe }
        assert_selector "img"
      end

      def test_media_has_overflow_hidden
        render_inline(Media::Component.new) { "Media" }
        assert_includes page.native.to_html, "overflow-hidden"
      end

      def test_media_with_aspect_ratio_16_9
        render_inline(Media::Component.new(aspect_ratio: "16/9")) { "Media" }
        assert_includes page.native.to_html, "aspect-[16/9]"
      end

      def test_media_with_aspect_ratio_4_3
        render_inline(Media::Component.new(aspect_ratio: "4/3")) { "Media" }
        assert_includes page.native.to_html, "aspect-[4/3]"
      end

      def test_media_with_aspect_ratio_1_1
        render_inline(Media::Component.new(aspect_ratio: "1/1")) { "Media" }
        assert_includes page.native.to_html, "aspect-square"
      end

      def test_media_with_custom_aspect_ratio
        render_inline(Media::Component.new(aspect_ratio: "21/9")) { "Media" }
        assert_includes page.native.to_html, "aspect-[21/9]"
      end

      def test_media_without_aspect_ratio
        render_inline(Media::Component.new) { "Media" }
        refute_includes page.native.to_html, "aspect-"
      end

      def test_media_with_padding_none
        render_inline(Media::Component.new(padding: :none)) { "Media" }
        refute_includes page.native.to_html, "px-[var(--card-padding-md)] pt-[var(--card-padding-md)]"
      end

      def test_media_with_padding_md
        render_inline(Media::Component.new(padding: :md)) { "Media" }
        assert_includes page.native.to_html, "px-[var(--card-padding-md)] pt-[var(--card-padding-md)]"
      end

      def test_media_merges_custom_classes_with_defaults
        render_inline(Media::Component.new(class: "custom-media", padding: :md)) { "Media" }
        html = page.native.to_html
        assert_includes html, "custom-media"
        assert_includes html, "overflow-hidden"
        assert_includes html, "px-[var(--card-padding-md)] pt-[var(--card-padding-md)]"
      end

      def test_media_validates_padding
        error = assert_raises(ArgumentError) do
          render_inline(Media::Component.new(padding: :invalid)) { "Media" }
        end

        assert_includes error.message, "Invalid padding"
      end

      # Stat Component Tests
      def test_stat_component_renders
        render_inline(Stat::Component.new(
          value: "2,543",
          label: "Total Users",
          trend: "12%",
          trend_direction: :up
        ))

        assert_text "2,543"
        assert_text "Total Users"
        assert_text "↑ 12%"
      end

      def test_stat_component_uses_up_trend_style
        render_inline(Stat::Component.new(
          value: "100",
          label: "Metric",
          trend: "8%",
          trend_direction: :up
        ))

        assert_includes page.native.to_html, "text-[var(--color-success-background-color)]"
      end

      def test_stat_component_uses_down_trend_style
        render_inline(Stat::Component.new(
          value: "100",
          label: "Metric",
          trend: "1.2%",
          trend_direction: :down
        ))

        assert_includes page.native.to_html, "text-[var(--color-danger-background-color)]"
        assert_text "↓ 1.2%"
      end

      def test_stat_component_accepts_custom_value_class
        render_inline(Stat::Component.new(
          value: "99",
          label: "Custom",
          trend: "4%",
          trend_direction: :up,
          value_class: "text-blue-600"
        ))

        assert_includes page.native.to_html, "text-blue-600"
      end

      def test_stat_component_validates_trend_direction
        error = assert_raises(ArgumentError) do
          render_inline(Stat::Component.new(
            value: "99",
            label: "Custom",
            trend: "4%",
            trend_direction: :sideways
          ))
        end

        assert_includes error.message, "Invalid trend_direction"
      end

      def test_stat_component_applies_style
        render_inline(Stat::Component.new(
          value: "$12,400",
          label: "Monthly revenue",
          trend: "+4%",
          trend_direction: :up,
          background: :brand
        ))

        html = page.native.to_html
        assert_includes html, "[background:var(--card-background-brand)]"
        assert_includes html, "[--surface-content-color:var(--card-background-brand-text-color)]"
        assert_includes html, 'data-background="brand"'
        assert_includes html, "fp-card"
      end

      def test_stat_component_rejects_unknown_style
        error = assert_raises(ArgumentError) do
          render_inline(Stat::Component.new(
            value: "1",
            label: "Count",
            trend: "0",
            trend_direction: :up,
            background: :flat
          ))
        end
        assert_includes error.message, "Invalid background"
      end

      # System Arguments Tests
      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class"))
        assert_includes page.native.to_html, "custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {controller: "card"}))
        assert_selector "div[data-controller='card']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(aria: {label: "Card label"}))
        assert_selector "div[aria-label='Card label']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(id: "custom-card"))
        assert_selector "div#custom-card"
      end

      # Integration Tests
      def test_strong_hover_applies_to_clickable_card
        render_inline(Component.new(hover: :strong, clickable: true, href: "/test"))
        assert_selector "a[href='/test']"
        html = page.native.to_html
        assert_includes html, "fp-card-hover-strong"
      end

      def test_card_has_rounded_corners
        render_inline(Component.new)
        assert_includes page.native.to_html, "rounded-[var(--card-radius)]"
      end

      def test_omitted_radius_matches_default
        render_inline(Component.new) { "Hi" }
        omitted = page.native.to_html

        render_inline(Component.new(radius: :default)) { "Hi" }
        chosen = page.native.to_html

        assert_equal omitted, chosen
        assert_includes chosen, "rounded-[var(--card-radius)]"
        refute_includes chosen, "--card-radius:"
        refute_includes chosen, "data-fp-card-radius"
      end

      def test_default_radius_keeps_caller_style_byte_for_byte
        render_inline(Component.new("style" => "color: red;")) { "Hi" }

        assert_includes page.native.to_html, 'style="color: red;"'
      end

      def test_radius_steps_set_an_inline_card_radius
        {
          none: "0px",
          sm: "var(--radius-sm)",
          md: "var(--radius-md)",
          lg: "var(--radius-lg)",
          xl: "var(--radius-xl)",
          xxl: "var(--radius-xxl)",
          xxxl: "var(--radius-xxxl)"
        }.each do |radius, length|
          render_inline(Component.new(radius: radius)) { "Hi" }
          assert_equal "--card-radius: #{length}", page.find(".fp-card")["style"]
        end
      end

      def test_radius_and_padding_do_not_imply_each_other
        render_inline(Component.new(radius: :lg, padding: :none)) { "Hi" }

        assert_selector ".fp-card[data-fp-card-padding='none']"
        assert_equal "--card-radius: var(--radius-lg)", page.find(".fp-card")["style"]
      end

      def test_radius_declaration_follows_the_caller_style
        render_inline(Component.new(:radius => :lg, "style" => "color: red;")) { "Hi" }

        style = page.find(".fp-card")["style"]
        assert_equal "color: red; --card-radius: var(--radius-lg)", style
      end

      def test_radius_declaration_strips_space_after_the_caller_semicolon
        render_inline(Component.new(:radius => :lg, "style" => "color: red; ")) { "Hi" }

        style = page.find(".fp-card")["style"]
        assert_equal "color: red; --card-radius: var(--radius-lg)", style
      end

      def test_default_card_omits_inset
        render_inline(Component.new) { "Hi" }

        html = page.native.to_html
        assert_equal "md", page.find(".fp-card")["data-fp-card-padding"]
        refute_includes html, "data-fp-card-inset"
        assert_includes html, "p-[var(--card-padding-md)]"
      end

      def test_inset_sets_the_data_attribute_without_padding
        render_inline(Component.new(padding: :none, inset: :sm)) { "Hi" }

        card = page.find(".fp-card")
        html = page.native.to_html
        assert_equal "none", card["data-fp-card-padding"]
        assert_equal "sm", card["data-fp-card-inset"]
        refute_includes html, "p-[var(--card-padding"
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        padding_rule = css.index('.fp-card[data-fp-card-padding="lg"]')
        inset_rule = css.index('.fp-card[data-fp-card-inset="sm"]')
        assert padding_rule < inset_rule
        assert_includes css, '.fp-card[data-fp-card-inset="sm"]'
        assert_includes css, "--card-inset: var(--card-padding-sm);"
        assert_includes css, '.fp-card[data-fp-card-inset="md"]'
        assert_includes css, "--card-inset: var(--card-padding-md);"
        assert_includes css, '.fp-card[data-fp-card-inset="lg"]'
        assert_includes css, "--card-inset: var(--card-padding-lg);"
      end

      def test_rejects_unknown_inset
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(inset: :none)) { "Hi" }
        end

        assert_match(/Invalid inset: none/, error.message)
      end

      def test_rejects_unknown_radius
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(radius: :bogus))
        end

        assert_match(/Invalid radius: bogus/, error.message)
      end

      def test_xxl_radius_stays_on_the_card_when_media_is_slotted
        render_inline(Component.new(radius: :xxl)) do |card|
          card.media(padding: :none) { "Photo" }
        end

        assert_equal "--card-radius: var(--radius-xxl)", page.find(".fp-card")["style"]
        assert_equal 1, page.native.to_html.scan("--card-radius:").size
        refute_includes page.find(".fp-card div").native.to_html, "--card-radius"
      end

      def test_xxxl_card_inner_media_nests_inside_the_card
        render_inline(Component.new(radius: :xxxl, padding: :md)) do |card|
          card.body do
            vc_test_controller.view_context.render(
              FlatPack::Media::Component.new(
                src: "/images/hero-stool.jpg",
                alt: "Stool",
                width: 1200,
                height: 800,
                radius: :card_inner
              )
            )
          end
        end

        card = page.find(".fp-card")
        assert_equal "md", card["data-fp-card-padding"]
        assert_equal "--card-radius: var(--radius-xxxl)", card["style"]
        frame = page.find(".fp-media__frame")
        assert_includes frame["class"], "fp-card-inner-radius"
        refute_includes frame.native.to_html, "--card-radius"
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        assert_includes css, "--card-inner-radius: max(0px, calc(var(--card-radius) - var(--card-inset)));"
        assert_includes css, '.fp-card[data-fp-card-padding="md"]'
        assert_includes css, "--card-inset: var(--card-padding-md);"
      end

      def test_card_radius_and_inner_media_radius_stay_separate
        render_inline(Component.new(radius: :lg)) do |card|
          card.body do
            vc_test_controller.view_context.render(
              FlatPack::Media::Component.new(
                src: "/images/hero-stool.jpg",
                alt: "Stool",
                width: 1200,
                height: 800,
                radius: :card_inner
              )
            )
          end
        end

        assert_equal "--card-radius: var(--radius-lg)", page.find(".fp-card")["style"]
        assert_selector ".fp-media__frame.fp-card-inner-radius"
        refute_includes page.find(".fp-media__frame").native.to_html, "--card-radius"
      end

      def test_stat_card_does_not_set_a_radius_style
        render_inline(Stat::Component.new(value: "12", label: "Open", trend: "4%", trend_direction: :up))

        refute_includes page.native.to_html, "--card-radius:"
        assert_includes page.native.to_html, "rounded-[var(--card-radius)]"
      end

      def test_card_without_media_has_overflow_visible
        render_inline(Component.new)
        assert_includes page.native.to_html, "overflow-visible"
      end

      def test_card_with_media_has_overflow_hidden
        render_inline(Component.new) do |component|
          component.media { "Media" }
        end

        assert_includes page.native.to_html, "overflow-hidden"
      end

      def test_media_overlay_keeps_a_host_text_class
        render_inline(
          FlatPack::Media::Component.new(
            src: "/images/hero-stool.jpg",
            alt: "Cover",
            width: 800,
            height: 800,
            class: "text-white"
          )
        ) do |media|
          media.with_item(placement: :top_right, inset: :sm) { "Mark" }
        end

        assert_includes page.find(".fp-overlay")[:class].split, "text-white"
      end

      def test_media_omits_hover_reveal_until_hover_actions_are_slotted
        render_inline(Component.new) do |component|
          component.media(padding: :none) { "Photo" }
        end

        html = page.native.to_html
        refute_includes html, "group/media"
        refute_includes html, "data-fp-card-media-part"
        refute_includes html, "[@media(hover:hover)]:opacity-0"
      end

      def test_media_hover_actions_reveal_on_hover_and_stay_visible_without_hover
        render_inline(Component.new) do |component|
          component.media(padding: :none) do |media|
            media.hover_actions { "Menu" }
            "Photo"
          end
        end

        html = page.native.to_html
        wrapper = page.find("[class*='group/media']")
        assert_includes wrapper[:class], "relative"
        assert_includes wrapper[:class], "overflow-hidden"
        assert_includes html, "Photo"
        item = page.find("[data-fp-card-media-part='hover-actions']")
        assert_equal "Menu", item.text
        assert_equal "top_right", item["data-fp-placement"]
        assert_equal "sm", item["data-fp-inset"]
        assert_includes item[:class], "opacity-100"
        assert_includes item[:class], "focus-within:opacity-100"
        assert_includes item[:class], "[@media(hover:hover)]:opacity-0"
        assert_includes item[:class], "[@media(hover:hover)]:group-hover/media:opacity-100"
        assert_includes item[:class], "motion-safe:duration-[var(--duration-fast)]"
        assert_includes item[:class], "motion-safe:ease-[var(--easing-standard)]"
        assert_includes item[:class], "motion-reduce:transition-none"
      end

      def test_media_hover_actions_accept_placement_and_inset
        render_inline(Component.new) do |component|
          component.media(padding: :none) do |media|
            media.hover_actions(placement: :bottom_left, inset: :lg) { "Save" }
          end
        end

        item = page.find("[data-fp-card-media-part='hover-actions']")
        assert_equal "bottom_left", item["data-fp-placement"]
        assert_equal "lg", item["data-fp-inset"]
        assert_includes item[:class], "bottom-[var(--fp-overlay-item-inset)]"
        assert_includes item[:class], "left-[var(--fp-overlay-item-inset)]"
      end

      def test_media_hover_actions_reject_unknown_placement
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |component|
            component.media(padding: :none) do |media|
              media.hover_actions(placement: :diagonal) { "No" }
            end
          end
        end

        assert_match(/Invalid placement/, error.message)
      end

      def test_media_hover_actions_reject_unknown_inset
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |component|
            component.media(padding: :none) do |media|
              media.hover_actions(inset: :xl) { "No" }
            end
          end
        end

        assert_match(/Invalid inset/, error.message)
      end

      def test_media_does_not_expose_with_hover_actions
        media = Media::Component.new
        assert_not_respond_to media, :with_hover_actions
        assert_not_respond_to media, :with_hover_actions_content
        assert_not_respond_to media, :with_hover_actions_slot
        assert_respond_to media, :hover_actions
      end

      def test_header_and_footer_follow_the_card_padding_step
        render_inline(Component.new(padding: :lg)) do |component|
          component.header { "Title" }
          component.footer { "Actions" }
        end

        html = page.native.to_html
        assert_includes html, "p-[var(--card-padding-lg)]"
        refute_includes html, "p-[var(--card-padding-md)]"
      end

      def test_slot_based_cards_do_not_apply_container_padding
        render_inline(Component.new(padding: :lg)) do |component|
          component.body { "Content" }
        end

        refute_includes page.native.to_html, "p-[var(--card-padding-lg)]"
        assert_includes page.native.to_html, "p-[var(--card-padding-md)]"
      end

      def test_media_slot_inherits_card_padding_by_default
        render_inline(Component.new(padding: :lg)) do |component|
          component.media(aspect_ratio: "16/9") { "Media" }
        end

        assert_includes page.native.to_html, "px-[var(--card-padding-lg)] pt-[var(--card-padding-lg)]"
      end

      def test_media_slot_padding_overrides_card_padding
        render_inline(Component.new(padding: :lg)) do |component|
          component.media(aspect_ratio: "16/9", padding: :none) { "Media" }
        end

        refute_includes page.native.to_html, "px-[var(--card-padding-lg)] pt-[var(--card-padding-lg)]"
        refute_includes page.native.to_html, "px-[var(--card-padding-md)] pt-[var(--card-padding-md)]"
      end

      def test_content_appears_when_no_slots_used
        render_inline(Component.new) { "Direct content" }
        assert_text "Direct content"
      end

      def test_content_not_rendered_when_slots_used
        render_inline(Component.new) do |component|
          component.body { "Body content" }
          "This should not appear"
        end
        assert_text "Body content"
        refute_text "This should not appear"
      end

      def test_multiple_style_variants_apply_correctly
        [:default, :none, :shaded, :brand, :brand_subtle, :gradient].each do |style|
          render_inline(Component.new(background: style))
          # Each style should render without errors
          assert_selector "div"
        end
      end

      def test_sanitizes_dangerous_attributes
        # This should not raise an error because FlatPack::AttributeSanitizer handles it
        render_inline(Component.new(onclick: "alert('xss')"))
        assert_selector "div"
        # onclick should be filtered out by sanitizer
        refute_includes page.native.to_html, "onclick"
      end

      def test_relative_urls_are_allowed
        render_inline(Component.new(clickable: true, href: "/posts/1"))
        assert_selector "a[href='/posts/1']"
      end

      def test_http_urls_are_allowed
        render_inline(Component.new(clickable: true, href: "http://example.com"))
        assert_selector "a[href='http://example.com']"
      end

      def test_https_urls_are_allowed
        render_inline(Component.new(clickable: true, href: "https://example.com"))
        assert_selector "a[href='https://example.com']"
      end

      def test_publishes_the_padding_step_on_the_root
        {none: "none", sm: "sm", md: "md", lg: "lg"}.each do |padding, step|
          render_inline(Component.new(padding: padding)) { "Hi" }
          assert_selector ".fp-card[data-fp-card-padding='#{step}']", count: 1
        end
      end

      def test_slotted_card_still_publishes_the_padding_step
        render_inline(Component.new(padding: :lg)) do |card|
          card.header { "Title" }
        end

        assert_selector ".fp-card[data-fp-card-padding='lg']"
        refute_includes page.find(".fp-card")[:class], "p-[var(--card-padding-lg)]"
        assert_includes page.native.to_html, "p-[var(--card-padding-lg)]"
      end

      def test_clickable_card_publishes_the_padding_step
        render_inline(Component.new(padding: :sm, clickable: true, href: "/posts/1")) { "Go" }
        assert_selector "a.fp-card[data-fp-card-padding='sm'][href='/posts/1']"
      end

      def test_card_padding_step_wins_over_a_host_data_attribute
        render_inline(Component.new(padding: :sm, data: {fp_card_padding: "lg"})) { "Hi" }
        assert_selector ".fp-card[data-fp-card-padding='sm']"
        refute_selector "[data-fp-card-padding='lg']"
      end

      def test_nested_card_publishes_its_own_padding_step
        render_inline(Component.new(padding: :lg)) do
          vc_test_controller.view_context.render(Component.new(padding: :none)) { "Inner" }
        end

        assert_selector ".fp-card[data-fp-card-padding='lg']"
        assert_selector ".fp-card[data-fp-card-padding='none']"
      end

      def test_stat_card_publishes_medium_padding_step
        render_inline(Stat::Component.new(value: "12", label: "Open", trend: "4%", trend_direction: :up))
        assert_selector ".fp-card[data-fp-card-padding='md']"
        assert_includes page.native.to_html, "p-[var(--card-padding-md)]"
      end

      def test_media_slot_keeps_the_card_radius
        render_inline(Component.new) do |card|
          card.media(padding: :none) { "Photo" }
        end

        assert_includes page.native.to_html, "rounded-[var(--card-radius)]"
        refute_includes page.native.to_html, "fp-card-inner-radius"
      end

      def test_kit_css_computes_the_inner_radius_on_the_card
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        variables = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read

        assert_includes css, "--card-inner-radius: max(0px, calc(var(--card-radius) - var(--card-inset)));"
        assert_includes css, '.fp-card[data-fp-card-padding="none"]'
        assert_includes css, "--card-inset: 0px;"
        assert_includes css, '.fp-card[data-fp-card-padding="sm"]'
        assert_includes css, "--card-inset: var(--card-padding-sm);"
        assert_includes css, '.fp-card[data-fp-card-padding="md"]'
        assert_includes css, "--card-inset: var(--card-padding-md);"
        assert_includes css, '.fp-card[data-fp-card-padding="lg"]'
        assert_includes css, "--card-inset: var(--card-padding-lg);"
        assert_includes css, ".fp-card-inner-radius {"
        assert_includes css, "border-radius: var(--card-inner-radius);"
        assert_includes css, ".fp-media__frame.fp-card-inner-radius {"
        refute_includes variables, "--card-inset"
        refute_includes variables, "--card-inner-radius"
      end

      def test_default_variant_stays_a_stacked_flex_column
        render_inline(Component.new) { "Note" }

        card = page.find(".fp-card")
        classes = card[:class].to_s.split
        assert_includes classes, "flex"
        assert_includes classes, "flex-col"
        refute_includes classes, "fp-card--featured"
        refute card[:data]&.include?("fp-card-variant")
        refute_includes page.native.to_html, "data-fp-card-variant"
      end

      def test_featured_slot_image_sets_cover_and_omits_h_auto
        render_inline(Component.new(variant: :featured)) do |card|
          card.media do |media|
            media.image(src: "/images/hero-stool.jpg", alt: "Cover", width: 800, height: 320)
          end
        end

        refute_includes page.find("img[alt='Cover']")[:class], "h-auto"
        assert_includes page.find("img[alt='Cover']")[:class], "fp-media__image"
      end

      def test_nested_card_media_outside_the_featured_slot_keeps_h_auto
        render_inline(Component.new(variant: :featured)) do |card|
          card.media do |media|
            media.image(src: "/images/hero-stool.jpg", alt: "Cover", width: 800, height: 320)
          end
          card.body do
            vc_test_controller.view_context.render(Component.new) do |nested|
              nested.body do
                vc_test_controller.view_context.render(
                  FlatPack::Media::Component.new(src: "/images/hero-stool.jpg", alt: "Nested", width: 800, height: 320)
                )
              end
            end
          end
        end

        refute_includes page.find("img[alt='Cover']")[:class], "h-auto"
        assert_includes page.find("img[alt='Nested']")[:class], "h-auto"
      end

      def test_featured_title_does_not_use_a_semibold_utility
        render_inline(Component.new(variant: :featured)) do |card|
          card.title { "Spring launch" }
        end

        refute_includes page.find(".fp-card__title")[:class].to_s.split, "font-semibold"
      end

      def test_stacked_media_keeps_h_auto
        render_inline(Component.new) do |card|
          card.media do
            vc_test_controller.view_context.render(
              FlatPack::Media::Component.new(src: "/images/hero-stool.jpg", alt: "Cover", width: 800, height: 320)
            )
          end
        end

        assert_includes page.find("img[alt='Cover']")[:class], "h-auto"
      end

      def test_featured_variant_uses_cover_layout_parts
        render_inline(Component.new(variant: :featured, padding: :none, inset: :md, radius: :xxxl, shadow: :md, border: :none)) do |card|
          card.media { "<img src='/images/hero-stool.jpg' alt='Cover'>".html_safe }
          card.header { "<button type='button'>Share</button>".html_safe }
          card.badge { "Northlight" }
          card.title(prefix: "Press kit: ") { "Spring launch" }
          card.body { "<p>Release date</p><p>3 Sep 2026</p>".html_safe }
          card.footer { "<button type='button'>Download kit</button>".html_safe }
        end

        html = page.native.to_html
        card = page.find(".fp-card")
        classes = card[:class].to_s.split
        assert_includes classes, "fp-card--featured"
        refute_includes classes, "flex-col"
        assert_equal "featured", card["data-fp-card-variant"]
        assert_selector "[data-fp-card-part='media']"
        assert_selector "[data-fp-card-part='copy']"
        assert_selector "[data-fp-card-part='header']", text: "Share"
        assert_selector "[data-fp-card-part='badge']", text: "Northlight"
        assert_selector "h2.fp-heading.fp-card__title", text: /Spring launch/
        assert_selector "[data-fp-card-part='title-prefix']", text: "Press kit: "
        assert_selector "[data-fp-card-part='body']", text: "Release date"
        assert_selector "[data-fp-card-part='footer']", text: "Download kit"
        assert_includes html, "aspect-square"
        refute_includes html, "border-b"
        refute_includes html, "border-t"
      end

      def test_featured_title_level_h1
        render_inline(Component.new(variant: :featured)) do |card|
          card.title(level: :h1) { "Harbour set" }
        end

        assert_selector "h1.fp-heading.fp-card__title", text: "Harbour set"
        refute_selector "h2.fp-card__title"
      end

      def test_title_level_accepts_an_integer
        render_inline(Component.new) do |card|
          card.title(level: 1) { "Harbour set" }
        end

        assert_selector "h1.fp-heading.fp-card__title", text: "Harbour set"
      end

      def test_featured_defaults_media_to_square_without_slot_padding
        render_inline(Component.new(variant: :featured, padding: :lg)) do |card|
          card.media { "Photo" }
        end

        html = page.native.to_html
        assert_includes html, "aspect-square"
        refute_includes html, "px-[var(--card-padding-lg)] pt-[var(--card-padding-lg)]"
        refute_includes html, "px-[var(--card-padding-md)] pt-[var(--card-padding-md)]"
      end

      def test_featured_without_media_still_renders_copy
        render_inline(Component.new(variant: :featured)) do |card|
          card.title { "No photo" }
          card.body { "Just the words." }
        end

        refute_selector "[data-fp-card-part='media']"
        assert_selector "[data-fp-card-part='copy']", text: "No photo"
        assert_selector "[data-fp-card-part='body']", text: "Just the words."
      end

      def test_default_variant_keeps_header_divider_when_badge_and_title_are_used
        render_inline(Component.new) do |card|
          card.header { "Tools" }
          card.badge { "Live" }
          card.title { "Stacked" }
          card.body { "Copy" }
        end

        html = page.native.to_html
        assert_includes html, "border-b"
        assert_selector "[data-fp-card-part='badge']", text: "Live"
        assert_selector "h2.fp-heading.fp-card__title", text: "Stacked"
        refute_includes html, "fp-card--featured"
      end

      def test_validates_variant
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(variant: :hero))
        end
        assert_includes error.message, "Invalid variant"
      end

      def test_integer_variant_raises_argument_error
        error = assert_raises(ArgumentError) do
          Component.new(variant: 1)
        end
        assert_includes error.message, "Invalid variant"
        assert_includes error.message, "1"
      end

      def test_title_rejects_an_unknown_level
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |card|
            card.title(level: :div) { "Nope" }
          end
        end
        assert_includes error.message, "Invalid level"
      end

      def test_kit_css_includes_featured_cover_rules
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

        assert_includes css, ".fp-card--featured"
        assert_includes css, ".fp-card__featured-media"
        assert_includes css, "aspect-ratio: 1 / 1"
        assert_includes css, "@media (max-width: 767px)"
        assert_includes css, "@media (min-width: 768px)"
        assert_includes css, "inset-inline-end: calc(var(--card-inset) + var(--overlay-edge-offset, 8px))"
        assert_includes css, ":where(.fp-card--featured)"
        assert_match(
          /@layer base \{.*?:where\(\.fp-card__featured-media\) \.fp-media__image \{[^}]*height: var\(--card-media-image-height, 100%\);/m,
          css
        )
        assert_includes css, "contain: size;"
        assert_includes css, "align-self: start;"
        refute_includes css, ":where(.fp-card__featured-media img) {\n  width: 100%;\n  height: 100%;"
        assert_includes css, "--card-title-size: var(--text-4xl);"
        assert_includes css, "--card-title-weight: var(--display-weight);"
        assert_includes css, "font-size: var(--card-title-size, var(--text-2xl));"
        assert_includes css, "font-weight: var(--card-title-weight, var(--display-weight));"
        assert_includes css, "flex: 1 1 calc(50% - var(--space-3));"
        refute_match(/\[data-fp-card-part="footer"\][^{]*\{\s*display:\s*contents/, css)
        refute_match(/\[data-fp-card-part="header"\][^{]*\{\s*display:\s*contents/, css)
        refute_includes css, ".fp-card--featured [data-fp-card-part=\"title\"] .fp-card__title"
        refute_match(/\.fp-card--featured \[data-fp-card-part="title"\]\s*\{[^}]*--card-title-size/, css)
      end

      def test_nil_variant_renders_the_stacked_card
        render_inline(Component.new(variant: nil)) do |card|
          card.body { "Stacked" }
        end

        refute_includes page.native.to_html, "fp-card--featured"
        assert_selector ".fp-card", text: "Stacked"
        assert_nil page.find(".fp-card")["data-fp-card-variant"]
      end

      def test_featured_title_does_not_inline_its_variables
        render_inline(Component.new(variant: :featured)) do |card|
          card.title { "Cover" }
        end

        refute page.find("[data-fp-card-part='title']")["style"]
        refute page.find(".fp-card")["style"]
      end

      def test_featured_header_element_keeps_host_chrome
        render_inline(Component.new(variant: :featured, padding: :none)) do |card|
          card.header(class: "host-header", divider: true, padding: :sm) { "Share" }
        end

        header = page.find("[data-fp-card-part='header'] > div")
        classes = header[:class].split
        assert_includes classes, "host-header"
        assert_includes classes, "border-b"
        assert_includes classes, "border-[var(--card-border-color)]"
        assert_includes classes, "p-[var(--card-padding-sm)]"
        assert_selector "[data-fp-card-part='header']", text: "Share"
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        assert_match(/:where\(\.fp-card--featured \[data-fp-card-part="header"\] > \*\)\s*\{\s*display:\s*flex/m, css)
      end

      def test_featured_footer_children_share_the_row
        render_inline(Component.new(variant: :featured, padding: :none)) do |card|
          card.footer { "<button type=\"button\">Contact</button><button type=\"button\">Download kit</button>".html_safe }
        end

        assert_selector "[data-fp-card-part='footer'] > div > button", count: 2
        assert_selector "[data-fp-card-part='footer'] button", text: "Contact"
        assert_selector "[data-fp-card-part='footer'] button", text: "Download kit"
      end
    end
  end
end
