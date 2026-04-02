# frozen_string_literal: true

require "json"

module FlatPack
  module Picker
    class Component < FlatPack::BaseComponent
      SELECTION_MODES = Config::SELECTION_MODES
      SEARCH_MODES = Config::SEARCH_MODES
      OUTPUT_MODES = Config::OUTPUT_MODES
      RESULTS_LAYOUTS = Config::RESULTS_LAYOUTS
      FORM_VALUE_MODES = FormConfig::VALUE_MODES
      ACCEPTED_KINDS = ItemNormalizer::ACCEPTED_KINDS

      def initialize(
        id:,
        items: [],
        title: "Select Assets",
        subtitle: nil,
        confirm_text: "Use Selected",
        close_text: "Close",
        size: :lg,
        selection_mode: :multiple,
        accepted_kinds: ACCEPTED_KINDS,
        searchable: false,
        search_placeholder: "Search assets...",
        search_mode: :local,
        search_endpoint: nil,
        search_param: "q",
        output_mode: :event,
        output_target: nil,
        context: {},
        empty_state_text: "No assets found",
        results_layout: :list,
        modal: false,
        auto_confirm: false,
        modal_body_height_mode: :fixed,
        modal_body_height: "clamp(20rem, 55vh, 30rem)",
        form: nil,
        **system_arguments
      )
        super(**system_arguments)
        @config = Config.new(
          id: id,
          title: title,
          subtitle: subtitle,
          confirm_text: confirm_text,
          close_text: close_text,
          size: size,
          selection_mode: selection_mode,
          accepted_kinds: accepted_kinds,
          searchable: searchable,
          search_placeholder: search_placeholder,
          search_mode: search_mode,
          search_endpoint: search_endpoint,
          search_param: search_param,
          output_mode: output_mode,
          output_target: output_target,
          context: context,
          empty_state_text: empty_state_text,
          results_layout: results_layout,
          modal: modal,
          auto_confirm: auto_confirm,
          modal_body_height_mode: modal_body_height_mode,
          modal_body_height: modal_body_height
        )
        @form = FormConfig.new(form: form, selection_mode: @config.selection_mode)
        @items = ItemNormalizer.call(items)
        @client_config = ClientConfig.new(config: @config, items: @items, form: @form)
      end

      def call
        return render_inline_picker unless @config.modal?

        render FlatPack::Modal::Component.new(
          id: @config.id,
          size: @config.size,
          body_height_mode: @config.modal_body_height_mode,
          body_height: @config.modal_body_height,
          **@system_arguments
        ) do |modal|
          modal.header { render_header_content }

          modal.body { render_picker_shell }
        end
      end

      private

      def render_inline_picker
        content_tag(:div, **inline_attributes) do
          safe_join([
            render_inline_header,
            content_tag(:div, render_picker_shell, **inline_body_attributes)
          ].compact)
        end
      end

      def render_picker_shell
        return render_picker_content unless @form.present?

        form_with(**picker_form_attributes) do
          render_picker_content
        end
      end

      def render_header_content
        safe_join([
          content_tag(:h2, @config.title, class: "text-lg font-semibold text-(--surface-content-color)"),
          (@config.subtitle.present? ? content_tag(:p, @config.subtitle, class: "mt-1 text-sm text-(--surface-muted-content-color)") : nil)
        ].compact)
      end

      def render_inline_header
        return unless @config.title.present? || @config.subtitle.present?

        content_tag(:div, render_header_content, class: "shrink-0")
      end

      def render_picker_content
        content_tag(:div, **picker_attributes) do
          safe_join([
            render_search_section,
            render_output_region,
            render_results_region,
            render_footer_actions
          ].compact)
        end
      end

      def render_search_section
        return unless @config.search.fetch(:enabled)

        render FlatPack::Search::Component.new(
          placeholder: @config.search_placeholder,
          name: "picker_query_#{@config.id}",
          max_width: :none,
          data: {
            flat_pack__picker_target: "searchInput",
            action: "input->flat-pack--picker#search"
          },
          aria: {
            label: "Search available assets"
          }
        )
      end

      def render_output_region
        safe_join([
          (@form.present? ? content_tag(:div, "", data: {flat_pack__picker_target: "formFields"}) : nil),
          tag.input(type: "hidden", data: {flat_pack__picker_target: "outputField"})
        ].compact)
      end

      def render_results_region
        content_tag(:div, class: "min-h-0 flex-1 overflow-y-auto") do
          safe_join([
            content_tag(:div, "", class: "space-y-2", data: {flat_pack__picker_target: "results"}),
            render_empty_state
          ])
        end
      end

      def render_empty_state
        content_tag(
          :div,
          @config.empty_state_text,
          class: "hidden h-full min-h-32 items-center justify-center rounded-md border border-dashed border-(--surface-border-color) p-4 text-center text-sm text-(--surface-muted-content-color)",
          data: {flat_pack__picker_target: "emptyState"}
        )
      end

      def render_footer_actions
        return if @config.auto_confirm_single_select?

        close_actions = ["click->flat-pack--picker#clearSelection"]
        close_actions << "click->flat-pack--modal#close" if @config.modal?

        confirm_actions = ["click->flat-pack--picker#confirmSelection"]
        confirm_actions << "click->flat-pack--modal#close" if @config.modal? && @form.blank?

        content_tag(:div, class: "mt-4 flex items-center justify-end gap-2") do
          safe_join([
            render(
              FlatPack::Button::Component.new(
                text: @config.close_text,
                style: :secondary,
                type: "button",
                data: {
                  action: close_actions.join(" ")
                }
              )
            ),
            render(
              FlatPack::Button::Component.new(
                text: @config.confirm_text,
                style: :primary,
                type: @form.present? ? "submit" : "button",
                data: {
                  action: confirm_actions.join(" ")
                }
              )
            )
          ])
        end
      end

      def picker_attributes
        {
          class: "flex h-full min-h-0 flex-col gap-4",
          data: {
            controller: "flat-pack--picker"
          }.merge(@client_config.data_attributes)
        }
      end

      def picker_form_attributes
        @form.form_with_attributes
      end

      def inline_attributes
        merge_attributes(
          id: @config.id,
          class: inline_wrapper_classes
        )
      end

      def inline_wrapper_classes
        classes(
          "relative",
          "flex",
          "flex-col",
          "min-h-0",
          "w-full",
          "overflow-hidden",
          FlatPack::Modal::Component::SIZES.fetch(@config.size),
          "p-4",
          "sm:p-6",
          "bg-[var(--modal-surface-color)]",
          "rounded-lg",
          "shadow-lg",
          "border",
          "border-[var(--modal-border-color)]"
        )
      end

      def inline_body_attributes
        attributes = {
          class: inline_body_classes
        }

        height_style = inline_body_style
        attributes[:style] = height_style if height_style.present?
        attributes
      end

      def inline_body_classes
        classes(
          "min-h-0",
          (@config.modal_body_height_mode == :auto) ? "flex-1" : "shrink-0",
          "overflow-y-auto",
          "py-4",
          "text-sm",
          "text-[var(--modal-body-color)]"
        )
      end

      def inline_body_style
        return nil unless @config.modal_body_height_mode != :auto

        case @config.modal_body_height_mode.to_sym
        when :fixed
          "--flatpack-modal-body-height: #{@config.modal_body_height}; height: var(--flatpack-modal-body-height);"
        when :min
          "--flatpack-modal-body-height: #{@config.modal_body_height}; min-height: var(--flatpack-modal-body-height);"
        end
      end
    end
  end
end
