# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ImageInput
    class ComponentTest < ViewComponent::TestCase
      PORTRAIT = "https://i.pravatar.cc/150?img=5"

      def test_renders_the_file_input_and_stage_controller
        render_inline(Component.new(name: "profile_photo"))

        assert_selector "input.sr-only[type='file'][name='profile_photo'][accept='image/*']", visible: :all
        assert_selector ".flat-pack-input-wrapper [data-controller='flat-pack--image-input']"
        assert_no_selector ".flat-pack-input-wrapper[data-controller='flat-pack--image-input']"
      end

      def test_wires_label_help_text_and_error
        render_inline(Component.new(
          name: "profile_photo",
          id: "profile-photo",
          label: "Profile photo",
          help_text: "PNG or JPEG.",
          error: "Choose an image"
        ))

        assert_selector "label[for='profile-photo']", text: "Profile photo"
        assert_selector "p#profile-photo_help_text", text: "PNG or JPEG."
        assert_selector "p#profile-photo_error", text: "Choose an image"
        assert_selector "input[aria-invalid='true'][aria-describedby='profile-photo_help_text profile-photo_error']", visible: :all
        empty = page.find("[data-flat-pack--image-input-target='empty']", visible: :all)
        refute_includes empty[:class], "border"
        surface = page.find("label.group")
        assert_includes surface[:class], "ring-[var(--color-error)]"
      end

      def test_filled_error_keeps_a_ring_on_the_surface
        render_inline(Component.new(name: "avatar", src: PORTRAIT, alt: "A person", error: "Choose an image"))

        surface = page.find("label.group")
        assert_includes surface[:class], "ring-[var(--color-error)]"
        assert_selector "img[src='#{PORTRAIT}']", visible: :all
      end

      def test_empty_state_hides_the_picture_and_the_clear_button
        render_inline(Component.new(name: "profile_photo", icon: "camera"))

        assert_no_selector "img"
        assert_selector "[data-flat-pack--image-input-target='preview'][hidden]", visible: :all
        empty = page.find("[data-flat-pack--image-input-target='empty']", visible: :all)
        assert_includes empty[:class], "bg-[var(--avatar-background-color)]"
        refute_includes empty[:class], "border"
        assert_selector "svg[data-flat-pack--icon-name-value='camera']", visible: :all
        assert_no_selector "button"
        assert_selector "button[hidden][aria-label='Remove image']", visible: :all
      end

      def test_clearable_false_omits_the_clear_button
        render_inline(Component.new(name: "avatar", src: PORTRAIT, alt: "A person", clearable: false))

        assert_no_selector "button", visible: :all
        assert_selector "img[src='#{PORTRAIT}']", visible: :all
      end

      def test_persisted_src_renders_preview_overlay_clear_and_remove
        render_inline(Component.new(
          name: "avatar",
          src: PORTRAIT,
          alt: "A person",
          clearable: true,
          remove_name: "remove_avatar"
        ))

        assert_selector "img[src='#{PORTRAIT}'][alt='A person']"
        assert_selector "[data-flat-pack--image-input-target='overlay'] svg[data-flat-pack--icon-name-value='pencil']"
        assert_selector "button[aria-label='Remove image']"
        assert_selector "input[type='hidden'][name='remove_avatar'][value='0'][autocomplete='off']", visible: :all
        assert_selector "[data-flat-pack--image-input-initial-src-value='#{PORTRAIT}']"
      end

      def test_shapes_and_sizes
        {
          circle: "rounded-[var(--avatar-radius-circle)]",
          rounded: "rounded-[var(--avatar-radius-rounded)]",
          square: "rounded-[var(--avatar-radius-square)]"
        }.each do |shape, shape_class|
          render_inline(Component.new(name: "photo", shape: shape, size: :md))

          label = page.find("label")
          assert_includes label[:class], shape_class
          assert_includes label[:class], "h-12 w-12"
        end

        render_inline(Component.new(name: "logo", shape: :rounded, size: :wide))
        assert_includes page.find("label")[:class], "h-20 w-36"

        render_inline(Component.new(name: "cover", size: "2xl"))
        assert_includes page.find("label")[:class], "h-24 w-24"
      end

      def test_default_size_and_shape
        render_inline(Component.new(name: "profile_photo"))

        label = page.find("label")
        assert_includes label[:class], "h-20 w-20"
        assert_includes label[:class], "rounded-[var(--avatar-radius-circle)]"
      end

      def test_rejects_invalid_options
        assert_raises(ArgumentError) { Component.new(name: "photo", size: :giant) }
        assert_raises(ArgumentError) { Component.new(name: "photo", shape: :triangle) }
        assert_raises(ArgumentError) { Component.new(name: " ") }
        assert_raises(ArgumentError) { Component.new(name: "photo", accept: ".exe") }
        assert_raises(ArgumentError) { Component.new(name: "avatar", remove_name: "avatar") }
        assert_raises(ArgumentError) { Component.new(name: "avatar", remove_name: " ") }
        assert_raises(ArgumentError) { Component.new(name: "avatar", src: "javascript:alert(1)") }
      end

      def test_blank_src_stays_empty_and_relative_src_renders
        render_inline(Component.new(name: "photo", src: "  "))
        assert_no_selector "img"

        render_inline(Component.new(name: "logo", src: "/masonry/studio.svg", alt: "Logo"))
        assert_selector "img[src='/masonry/studio.svg'][alt='Logo']"
      end

      def test_disabled_and_required
        render_inline(Component.new(
          name: "avatar_disabled",
          src: PORTRAIT,
          alt: "A person",
          label: "Locked",
          disabled: true,
          required: true
        ))

        assert_selector "input[type='file'][disabled][required]", visible: :all
        assert_selector "button[disabled][aria-label='Remove image']"
        assert_selector "[aria-disabled='true'].pointer-events-none"
        assert_selector "img[src='#{PORTRAIT}']"
      end

      def test_names_the_file_input_from_alt_when_there_is_no_label
        render_inline(Component.new(name: "avatar", alt: "A person"))

        assert_selector "input[aria-label='A person']", visible: :all
      end

      def test_input_attributes_merge_without_replacing_type_or_name
        render_inline(Component.new(
          name: "profile_photo",
          input_attributes: {
            type: "text",
            name: "hijack",
            class: "host-class",
            data: {controller: "host-input", action: "change->host#pick"}
          }
        ))

        input = page.find("input[type='file'][name='profile_photo']", visible: :all)
        assert_includes input[:class], "sr-only"
        assert_includes input[:class], "host-class"
        assert_includes input["data-controller"], "host-input"
        assert_includes input["data-controller"], "flat-pack--form-validation"
        assert_includes input["data-action"], "change->flat-pack--image-input#choose"
        assert_includes input["data-action"], "change->host#pick"
        assert_equal "input", input["data-flat-pack--image-input-target"]
      end

      def test_system_arguments_land_on_the_wrapper
        render_inline(Component.new(
          name: "profile_photo",
          id: "profile-photo",
          class: "mt-6",
          data: {controller: "host-form", testid: "photo-field"},
          aria: {describedby: "outside"}
        ))

        wrapper = page.find(".flat-pack-input-wrapper")
        assert_includes wrapper[:class], "flat-pack-input-wrapper"
        assert_includes wrapper[:class], "mt-6"
        assert_includes wrapper["data-controller"], "host-form"
        assert_equal "photo-field", wrapper["data-testid"]
        assert_equal "outside", wrapper["aria-describedby"]
        assert_selector "input#profile-photo", visible: :all

        input = page.find("input[type='file']", visible: :all)
        refute_includes input["data-controller"].to_s, "host-form"
      end

      def test_clear_attributes_merge_onto_the_button
        render_inline(Component.new(
          name: "avatar",
          src: PORTRAIT,
          alt: "A person",
          clear_attributes: {type: "submit", data: {confirm: "yes"}}
        ))

        button = page.find("button[aria-label='Remove image']")
        assert_equal "button", button[:type]
        assert_equal "yes", button["data-confirm"]
        assert_includes button["data-action"], "click->flat-pack--image-input#clear"
      end

      def test_content_block_renders_inside_the_stage
        render_inline(Component.new(name: "profile_photo")) do
          %(<input type="hidden" name="crop_x">).html_safe
        end

        assert_selector "[data-controller='flat-pack--image-input'] input[name='crop_x']", visible: :all
      end

      def test_nil_accept_omits_the_attribute
        render_inline(Component.new(name: "profile_photo", accept: nil))

        input = page.find("input[type='file']", visible: :all)
        assert_nil input[:accept]
      end
    end
  end
end
