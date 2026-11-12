# frozen_string_literal: true

require "test_helper"

module FlatPack
  module FloatingFrame
    class ComponentTest < ViewComponent::TestCase
      def test_launcher_exposes_label_expanded_and_controls
        render_inline(frame(id: "notes-frame"))

        button = page.find("button.fp-fab__trigger")

        assert_equal "notes-frame-trigger", button[:id]
        assert_equal "Open notes", button[:"aria-label"]
        assert_equal "false", button[:"aria-expanded"]
        assert_equal "notes-frame-panel", button[:"aria-controls"]
        assert_equal "dialog", button[:"aria-haspopup"]
        assert_equal "bottom_left", page.find(".fp-fab")[:"data-fp-position"]
      end

      def test_panel_is_a_dialog_named_by_the_heading
        render_inline(frame(id: "notes-frame"))

        panel = page.find("#notes-frame-panel")

        assert_equal "dialog", panel[:role]
        assert_equal "notes-frame-title", panel[:"aria-labelledby"]
        assert_equal "true", panel[:"aria-hidden"]
        assert_equal "notes-frame-trigger", panel[:"data-flat-pack--popover-trigger-id-value"]
        assert_equal "top", panel[:"data-flat-pack--popover-placement-value"]
        assert_selector "h2#notes-frame-title", text: "Notes"
        close = page.find("button[aria-label='Close']")
        action = close[:"data-action"]
        assert_includes action, "flat-pack--floating-frame#prepareRestore"
        assert_operator action.index("prepareRestore"), :<, action.index("popover#close")
        assert_nil page.find("#notes-frame-panel")[:"aria-modal"]
      end

      def test_content_padding_defaults_to_the_card_md_step
        render_inline(frame(id: "notes-frame"))

        mount = page.find("#notes-frame [data-flat-pack--floating-frame-target='mount']", visible: :all)

        assert_includes mount[:class], "fp-floating-frame__mount"
        assert_includes mount[:class], "p-[var(--card-padding-md)]"
      end

      def test_padding_accepts_the_card_sizes
        render_inline(frame(padding: :sm, id: "notes-frame"))
        assert_includes mount_class, "p-[var(--card-padding-sm)]"

        render_inline(frame(padding: :lg, id: "notes-frame"))
        assert_includes mount_class, "p-[var(--card-padding-lg)]"

        render_inline(frame(padding: :none, id: "notes-frame"))
        refute_includes mount_class, "p-[var(--card-padding-"
      end

      def test_content_fill_uses_the_page_background_token
        css = File.read(FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css"))
        panel = File.read(FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css"))

        assert_match(
          /--floating-frame-background:\s*var\(--surface-background-color\)/,
          css
        )
        assert_includes panel, "background-color: var(--floating-frame-background)"

        render_inline(frame(id: "notes-frame"))
        root = page.find("#notes-frame")
        assert_nil root[:style]
      end

      def test_background_sets_the_fill_variable
        render_inline(frame(background: "var(--surface-page-background-color)", style: "color: red"))

        style = page.find(".fp-floating-frame")[:style]
        assert_includes style, "--floating-frame-background: var(--surface-page-background-color)"
        assert_includes style, "color: red"
      end

      def test_background_merges_a_string_style_key
        component = frame(background: "transparent", style: "color: red")
        component.instance_variable_get(:@system_arguments)["style"] = "outline: none"
        render_inline(component)

        style = page.find(".fp-floating-frame")[:style]
        assert_includes style, "--floating-frame-background: transparent"
        assert_includes style, "color: red"
        assert_includes style, "outline: none"
        root = rendered_content[/<div[^>]*class="fp-floating-frame"[^>]*>/]
        assert_equal 1, root.scan(/\bstyle="/).size
      end

      def test_content_class_padding_overrides_the_mount_padding
        render_inline(frame(content_class: "p-0"))

        classes = page.find(".fp-floating-frame__mount")[:class]
        assert_includes classes, "p-0"
        refute_includes classes, "p-[var(--card-padding-md)]"
      end

      def test_content_class_is_added_to_the_mount
        render_inline(frame(content_class: "bg-[var(--color-danger-background-color)]"))

        mount = page.find(".fp-floating-frame__mount")
        assert_includes mount[:class], "fp-floating-frame__mount"
        assert_includes mount[:class], "p-[var(--card-padding-md)]"
        assert_includes mount[:class], "bg-[var(--color-danger-background-color)]"
        assert_nil mount[:style]
      end

      def test_rejects_a_non_string_content_class
        error = assert_raises(ArgumentError) { frame(content_class: [:bg]) }
        assert_match(/content_class/, error.message)
      end

      def test_rejects_an_unsafe_background
        error = assert_raises(ArgumentError) { frame(background: "red; color: blue") }
        assert_match(/Invalid background/, error.message)
      end

      def test_rejects_an_unknown_padding
        error = assert_raises(ArgumentError) { frame(padding: :xl) }
        assert_match(/Invalid padding/, error.message)
      end

      def test_top_corners_open_the_panel_downward
        render_inline(frame(position: :top_right))

        assert_equal "bottom", page.find(".fp-floating-frame__panel")[:"data-flat-pack--popover-placement-value"]
      end

      def test_iframe_stays_in_the_template_until_open
        render_inline(frame(id: "notes-frame"))

        iframe = iframe_in_template

        assert_no_live_iframe
        assert_equal "/notes", attribute(iframe, "src")
        assert_equal "Notes", attribute(iframe, "title")
        assert_equal "lazy", attribute(iframe, "loading")
        assert_selector "[data-flat-pack--floating-frame-target='mount']", visible: :all
      end

      def test_sandbox_defaults_to_a_list_without_top_navigation
        render_inline(frame)

        sandbox = attribute(iframe_in_template, "sandbox")

        assert_equal Component::DEFAULT_SANDBOX, sandbox
        refute_includes sandbox, "allow-top-navigation"
      end

      def test_sandbox_and_allow_pass_through
        render_inline(
          frame(
            sandbox: "allow-scripts allow-top-navigation-by-user-activation",
            allow: "microphone",
            allowfullscreen: true
          )
        )

        iframe = iframe_in_template

        assert_equal "allow-scripts allow-top-navigation-by-user-activation", attribute(iframe, "sandbox")
        assert_equal "microphone", attribute(iframe, "allow")
        assert_includes iframe, "allowfullscreen"
      end

      def test_empty_sandbox_is_strict
        render_inline(frame(sandbox: ""))

        assert_equal "", attribute(iframe_in_template, "sandbox")
      end

      def test_omits_allow_when_unset
        render_inline(frame)

        refute_includes rendered_content, "allow="
      end

      def test_label_is_required
        error = assert_raises(ArgumentError) { frame(label: "  ") }
        assert_equal "label is required", error.message

        type = assert_raises(ArgumentError) { frame(label: nil) }
        assert_equal "label must be a String", type.message
      end

      def test_src_must_be_http_or_relative
        error = assert_raises(ArgumentError) { frame(src: "javascript:alert(1)") }
        assert_match(/Invalid src/, error.message)
      end

      def test_rejects_an_unknown_position
        error = assert_raises(ArgumentError) { frame(position: :middle) }
        assert_match(/Invalid position/, error.message)
      end

      def test_mobile_panel_is_near_fullscreen
        css = File.read(FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css"))

        assert_includes css, ".fp-floating-frame__panel[aria-hidden=\"false\"]"
        assert_match(
          /@media \(max-width: 639px\)[\s\S]*\.fp-floating-frame__panel\[aria-hidden="false"\][\s\S]*100vw[\s\S]*100dvh/,
          css
        )
      end

      private

      def mount_class
        page.find("[data-flat-pack--floating-frame-target='mount']", visible: :all)[:class].to_s
      end

      def iframe_in_template
        html = rendered_content
        match = html.match(%r{<template\b[^>]*>([\s\S]*?)</template>})
        flunk "expected the embed to render inside a template" if match.nil?

        match[1]
      end

      def assert_no_live_iframe
        outside = rendered_content.gsub(%r{<template\b[\s\S]*?</template>}, "")

        refute_includes outside, "<iframe"
      end

      def attribute(html, name)
        match = html.match(/\b#{Regexp.escape(name)}="([^"]*)"/)
        match && match[1]
      end

      def frame(**options)
        Component.new(
          src: "/notes",
          title: "Notes",
          label: "Open notes",
          position: :bottom_left,
          **options
        )
      end
    end
  end
end
