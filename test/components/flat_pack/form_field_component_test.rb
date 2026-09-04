# frozen_string_literal: true

require "test_helper"

module FlatPack
  module FormField
    class ComponentTest < ViewComponent::TestCase
      def test_renders_label_control_help_and_error
        render_inline(
          Component.new(
            label: "Email",
            error: "Required",
            help_text: "Work email preferred",
            field_id: "user_email",
            class: "flat-pack-input-wrapper"
          )
        ) do |field|
          field.with_control { "<input id='user_email' type='email' class='flat-pack-input'>".html_safe }
        end

        assert_selector ".flat-pack-input-wrapper"
        assert_selector "label[for='user_email']", text: "Email"
        assert_selector "input#user_email[type='email']"
        assert_selector "p#user_email_help_text", text: "Work email preferred"
        assert_selector "p#user_email_error", text: "Required"
      end

      def test_renders_after_help_slot_between_help_and_error
        render_inline(
          Component.new(
            help_text: "Help",
            error: "Error",
            field_id: "title",
            class: "flat-pack-input-wrapper"
          )
        ) do |field|
          field.with_control { "<input id='title'>".html_safe }
          field.with_after_help { "<p id='title_character_count'>0 characters</p>".html_safe }
        end

        html = page.native.to_html
        help_index = html.index("title_help_text")
        count_index = html.index("title_character_count")
        error_index = html.index("title_error")

        assert help_index
        assert count_index
        assert error_index
        assert_operator help_index, :<, count_index
        assert_operator count_index, :<, error_index
      end

      def test_select_wrapper_class_supported
        render_inline(
          Component.new(
            label: "Country",
            field_id: "country",
            class: "flat-pack-select-wrapper"
          )
        ) do |field|
          field.with_control { "<select id='country'></select>".html_safe }
        end

        assert_selector ".flat-pack-select-wrapper"
        assert_selector "label[for='country']", text: "Country"
      end

      def test_custom_help_text_class_without_default_margin
        render_inline(
          Component.new(
            help_text: "Plain help",
            field_id: "notes",
            help_text_class: "text-xs text-[var(--surface-muted-content-color)]"
          )
        ) do |field|
          field.with_control { "<textarea id='notes'></textarea>".html_safe }
        end

        help = page.find("p#notes_help_text")
        assert_includes help[:class], "text-xs"
        refute_includes help[:class].split, "mt-1"
      end
    end

    class ControlStylesTest < ViewComponent::TestCase
      class Probe < FlatPack::BaseComponent
        include FlatPack::FormField::ControlStyles

        def initialize(error: false, custom_class: nil, **kwargs)
          @error = error
          @custom_class = custom_class
          super(**kwargs)
        end

        def call
          content_tag(:div, class: form_control_classes(error: @error, custom_class: @custom_class))
        end
      end

      def test_shared_box_classes_use_form_control_padding_token
        render_inline(Probe.new)

        html = page.native.to_html
        assert_includes html, "flat-pack-input"
        assert_includes html, "px-[var(--form-control-padding)]"
        assert_includes html, "py-[var(--form-control-padding)]"
        assert_includes html, "border-[var(--surface-border-color)]"
      end

      def test_error_uses_error_border_token
        render_inline(Probe.new(error: true))

        assert_includes page.native.to_html, "border-[var(--color-error)]"
      end
    end

    class CompositionTest < ViewComponent::TestCase
      COMPONENTS = [
        FlatPack::TextInput::Component,
        FlatPack::EmailInput::Component,
        FlatPack::PhoneInput::Component,
        FlatPack::UrlInput::Component,
        FlatPack::NumberInput::Component,
        FlatPack::PasswordInput::Component,
        FlatPack::SearchInput::Component,
        FlatPack::TextArea::Component,
        FlatPack::Select::Component,
        FlatPack::DateInput::Component,
        FlatPack::TimeInput::Component,
        FlatPack::DateTimeInput::Component
      ].freeze

      def test_listed_inputs_include_control_styles
        COMPONENTS.each do |component_class|
          assert_includes component_class.included_modules, FlatPack::FormField::ControlStyles,
            "#{component_class} should include FormField::ControlStyles"
        end
      end

      def test_listed_inputs_compose_form_field_in_call
        COMPONENTS.each do |component_class|
          source = File.read(component_class.instance_method(:call).source_location.first)
          assert_includes source, "FlatPack::FormField::Component",
            "#{component_class} should compose FormField::Component"
        end
      end

      def test_email_public_api_kwargs_unchanged
        kwargs = FlatPack::EmailInput::Component.instance_method(:initialize).parameters
        names = kwargs.map(&:last)
        assert_includes names, :name
        assert_includes names, :value
        assert_includes names, :placeholder
        assert_includes names, :disabled
        assert_includes names, :required
        assert_includes names, :label
        assert_includes names, :error
        assert_includes names, :help_text
        assert_includes names, :system_arguments
      end

      def test_select_public_api_kwargs_unchanged
        names = FlatPack::Select::Component.instance_method(:initialize).parameters.map(&:last)
        %i[
          name options value label placeholder disabled required searchable
          search_mode search_endpoint search_param min_search_length multiple
          error help_text system_arguments
        ].each do |expected|
          assert_includes names, expected
        end
      end
    end
  end
end
