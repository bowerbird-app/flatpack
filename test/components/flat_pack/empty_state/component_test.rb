# frozen_string_literal: true

require "test_helper"

module FlatPack
  module EmptyState
    class ComponentTest < ViewComponent::TestCase
      def test_renders_empty_state_with_title
        render_inline(Component.new(title: "No results found"))

        assert_selector "h3", text: "No results found"
        assert_includes page.native.to_html, "fp-text-balance"
        assert_includes page.native.to_html, "fp-empty-state"
      end

      def test_renders_empty_state_with_description
        render_inline(Component.new(
          title: "No results",
          description: "Try adjusting your search"
        ))

        assert_selector "h3", text: "No results"
        assert_selector "p", text: "Try adjusting your search"
      end

      def test_root_stretches_and_text_uses_the_medium_measure
        render_inline(Component.new(title: "Nothing here", description: "Try again later."))

        root = page.find(".fp-empty-state")
        refute_includes root[:class].to_s, "max-w-"
        refute_includes root[:class].to_s, "w-fit"
        refute_includes root[:class].to_s, "inline-block"
        assert_includes page.native.to_html, "max-w-[var(--empty-state-measure-md)]"
        refute_includes page.native.to_html, "max-w-md"
      end

      def test_does_not_render_icon_by_default
        render_inline(Component.new(title: "Empty"))

        assert_no_selector "svg"
      end

      def test_renders_explicit_inbox_icon
        render_inline(Component.new(title: "Empty", icon: :inbox))

        assert_selector "svg[data-flat-pack--icon-name-value='inbox']"
      end

      def test_renders_icon_variant
        render_inline(Component.new(title: "Empty", icon: :sparkles, icon_variant: :solid))

        assert_selector "svg[data-flat-pack--icon-name-value='sparkles'][data-flat-pack--icon-variant-value='solid']"
      end

      def test_does_not_render_icon_when_icon_is_nil
        render_inline(Component.new(title: "Empty", icon: nil))

        assert_no_selector "svg"
      end

      def test_renders_search_icon
        render_inline(Component.new(title: "No results", icon: :search))

        assert_selector "svg[data-flat-pack--icon-name-value='magnifying-glass']"
      end

      def test_renders_custom_icon_name
        render_inline(Component.new(title: "No uploads", icon: :upload))

        assert_selector "svg[data-flat-pack--icon-name-value='arrow-up-tray']"
      end

      def test_renders_items_in_a_wrapping_collection
        render_inline(Component.new(title: "Empty")) do |component|
          component.item { "Upload" }
          component.item { "Connect" }
        end

        assert_selector "ul.flex.flex-wrap.justify-center > li", count: 2
        assert_text "Upload"
        assert_text "Connect"
        assert_includes page.native.to_html, "gap: var(--empty-state-gap-md)"
      end

      def test_renders_stacked_actions
        render_inline(Component.new(title: "Empty", layout: :stack)) do |component|
          component.item { "Upload" }
          component.item { "Connect" }
        end

        assert_selector "ul.flex.flex-col.w-full > li", count: 2
        refute_selector "ul.items-center"
        assert_text "Upload"
        assert_text "Connect"
        refute_selector "ul.flex-wrap"
      end

      def test_does_not_render_a_collection_without_items
        render_inline(Component.new(title: "Empty"))

        assert_no_selector "ul"
      end

      def test_renders_custom_visual_outside_the_measure
        render_inline(Component.new(title: "Empty", icon: :inbox)) do |component|
          component.visual { "Custom mark" }
        end

        assert_text "Custom mark"
        mark = page.find(".fp-empty-state > div", text: "Custom mark", match: :first)
        assert_includes mark[:class], "w-full"
        refute_includes mark[:class], "max-w-[var(--empty-state-measure-md)]"
        assert_no_selector "svg"
      end

      def test_renders_media_with_its_own_aspect_ratio_inside_the_measure
        render_inline(Component.new(title: "Empty", width: :sm)) do |component|
          component.media(src: "/images/hero-stool.jpg", alt: "A wooden stool", width: 1280, height: 850)
        end

        assert_selector "img[src='/images/hero-stool.jpg'][alt='A wooden stool'][width='1280'][height='850']"
        assert_includes page.native.to_html, "aspect-ratio: 1280 / 850"
        assert_includes page.native.to_html, "max-w-[var(--empty-state-measure-sm)]"
        assert_no_selector "svg"
      end

      def test_media_replaces_the_icon
        render_inline(Component.new(title: "Empty", icon: :inbox, width: :sm)) do |component|
          component.media(src: "/images/hero-stool.jpg", alt: "A wooden stool", width: 1280, height: 850)
        end

        assert_selector "img[alt='A wooden stool']"
        assert_no_selector "svg"
      end

      def test_raises_when_visual_and_media_are_both_set
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(title: "Empty")) do |component|
            component.visual { "Mark" }
            component.media(src: "/images/hero-stool.jpg", alt: "Stool", width: 1280, height: 850)
          end
        end

        assert_includes error.message, "visual or media"
      end

      def test_raises_when_media_is_given_a_block
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(title: "Empty")) do |component|
            component.media(src: "/images/hero-stool.jpg", alt: "Stool", width: 1280, height: 850) { "Mark" }
          end
        end

        assert_includes error.message, "Pass markup with visual"
      end

      def test_does_not_expose_removed_slot_aliases
        component = Component.new(title: "Empty")

        assert_not_respond_to component, :with_actions
        assert_not_respond_to component, :with_graphic
        assert_not_respond_to component, :graphic
        assert_not_respond_to component, :with_visual
        assert_not_respond_to component, :with_media
        assert_not_respond_to component, :with_item
        assert_not_respond_to component, :slot
        assert_not_respond_to component, :actions
      end

      def test_raises_error_without_title
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_raises_error_for_non_symbol_or_string_icon
        assert_raises(ArgumentError) do
          Component.new(title: "Empty", icon: 123)
        end
      end

      def test_accepts_false_icon_value
        render_inline(Component.new(title: "Empty", icon: false))

        assert_no_selector "svg"
      end

      def test_icon_variant_requires_an_icon
        error = assert_raises(ArgumentError) do
          Component.new(title: "Empty", icon_variant: :solid)
        end

        assert_includes error.message, "icon_variant requires icon"
      end

      def test_raises_for_invalid_icon_variant
        error = assert_raises(ArgumentError) do
          Component.new(title: "Empty", icon: :inbox, icon_variant: :thick)
        end

        assert_includes error.message, "Invalid icon_variant"
      end

      def test_accepts_custom_classes
        render_inline(Component.new(title: "Empty", class: "custom-class"))

        assert_selector "div.custom-class"
      end

      def test_default_size_uses_density_padding_tokens
        render_inline(Component.new(title: "Nothing here", description: "Try again later."))

        html = page.native.to_html
        assert_includes html, "py-[var(--empty-state-padding-y-md)]"
        assert_includes html, "px-[var(--empty-state-padding-x-md)]"
        assert_includes page.find("h3")[:class], "text-[length:var(--text-lg)]"
        assert_includes page.find("p")[:class], "text-[length:var(--text-base)]"
        assert_no_selector "svg"
        refute_includes html, "py-12"
        refute_includes html, "px-4"
      end

      def test_renders_small_size
        render_inline(Component.new(title: "Nothing here", description: "Try again later.", icon: :inbox, size: :sm))

        html = page.native.to_html
        assert_includes html, "py-[var(--empty-state-padding-y-sm)]"
        assert_includes html, "px-[var(--empty-state-padding-x-sm)]"
        assert_includes page.find("h3")[:class], "text-[length:var(--text-base)]"
        assert_includes page.find("p")[:class], "text-[length:var(--text-sm)]"
        assert_selector "svg.w-5.h-5"
      end

      def test_renders_large_size
        render_inline(Component.new(title: "Nothing here", description: "Try again later.", icon: :inbox, size: :lg))

        html = page.native.to_html
        assert_includes html, "py-[var(--empty-state-padding-y-lg)]"
        assert_includes html, "px-[var(--empty-state-padding-x-lg)]"
        assert_includes page.find("h3")[:class], "text-[length:var(--text-xl)]"
        assert_includes page.find("p")[:class], "text-[length:var(--text-lg)]"
        assert_selector "svg.w-8.h-8"
      end

      def test_default_size_uses_the_large_icon
        render_inline(Component.new(title: "Nothing here", icon: :inbox))

        assert_selector "svg.w-6.h-6"
      end

      def test_description_size_overrides_the_preset
        render_inline(Component.new(
          title: "Nothing here",
          description: "Try again later.",
          size: :md,
          description_size: :xl
        ))

        assert_includes page.find("h3")[:class], "text-[length:var(--text-lg)]"
        assert_includes page.find("p")[:class], "text-[length:var(--text-xl)]"
        assert_includes page.native.to_html, "py-[var(--empty-state-padding-y-md)]"
      end

      def test_description_size_can_stay_small_on_a_large_preset
        render_inline(Component.new(
          title: "Nothing here",
          description: "Try again later.",
          size: :lg,
          description_size: :sm
        ))

        assert_includes page.find("h3")[:class], "text-[length:var(--text-xl)]"
        assert_includes page.find("p")[:class], "text-[length:var(--text-sm)]"
        assert_includes page.native.to_html, "py-[var(--empty-state-padding-y-lg)]"
      end

      def test_icon_size_overrides_the_preset
        render_inline(Component.new(title: "Nothing here", icon: :inbox, size: :lg, icon_size: :sm))

        assert_selector "svg.w-4.h-4"
        assert_includes page.native.to_html, "py-[var(--empty-state-padding-y-lg)]"
      end

      def test_icon_size_requires_an_icon
        error = assert_raises(ArgumentError) do
          Component.new(title: "Nothing here", icon_size: :lg)
        end

        assert_includes error.message, "icon_size requires icon"
      end

      def test_raises_for_invalid_description_size
        error = assert_raises(ArgumentError) do
          Component.new(title: "Nothing here", description_size: :base)
        end

        assert_includes error.message, "Invalid description_size"
      end

      def test_raises_for_invalid_icon_size
        error = assert_raises(ArgumentError) do
          Component.new(title: "Nothing here", icon: :inbox, icon_size: :xxl)
        end

        assert_includes error.message, "Invalid icon_size"
      end

      def test_title_size_overrides_the_density_heading
        render_inline(Component.new(title: "Nothing here", size: :sm, title_size: :display))

        assert_selector "h3.fp-display", text: "Nothing here"
        refute_includes page.find("h3")[:class], "font-semibold"
      end

      def test_title_size_xxl_uses_the_text_token
        render_inline(Component.new(title: "Nothing here", title_size: :xxl))

        assert_includes page.find("h3")[:class], "text-[length:var(--text-2xl)]"
      end

      def test_width_presets
        %i[sm lg full].each do |width|
          render_inline(Component.new(title: "Nothing here", width: width))

          assert_includes page.native.to_html, "max-w-[var(--empty-state-measure-#{width})]"
        end
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(title: "Nothing here", size: :xl)
        end

        assert_includes error.message, "Invalid size"
      end

      def test_raises_error_for_invalid_width
        error = assert_raises(ArgumentError) do
          Component.new(title: "Nothing here", width: :xs)
        end

        assert_includes error.message, "Invalid width"
      end

      def test_raises_error_for_invalid_layout
        error = assert_raises(ArgumentError) do
          Component.new(title: "Nothing here", layout: :grid)
        end

        assert_includes error.message, "Invalid layout"
      end

      def test_raises_error_for_invalid_title_size
        error = assert_raises(ArgumentError) do
          Component.new(title: "Nothing here", title_size: :huge)
        end

        assert_includes error.message, "Invalid title_size"
      end

      def test_padding_tokens_are_space_times_density
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read

        assert_includes css, "--empty-state-padding-y-sm: round(nearest, calc(var(--space-6) * var(--density)), 1px);"
        assert_includes css, "--empty-state-padding-x-md: round(nearest, calc(var(--space-4) * var(--density)), 1px);"
        assert_includes css, "--empty-state-padding-y-md: round(nearest, calc((var(--space-6) + var(--space-4)) * var(--density)), 1px);"
        assert_includes css, "--empty-state-padding-y-lg: round(nearest, calc(var(--space-6) * 2 * var(--density)), 1px);"
        assert_includes css, "--empty-state-measure-md: 28rem;"
        assert_includes css, "--empty-state-measure-full: none;"

        source = FlatPack::Engine.root.join("app/components/flat_pack/empty_state/component.rb").read
        refute_includes source, "py-8"
        refute_includes source, "py-12"
        refute_includes source, "py-16"
        refute_includes source, "px-3"
        refute_includes source, "px-4"
        refute_includes source, "px-6"
      end
    end
  end
end
