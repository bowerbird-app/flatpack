# frozen_string_literal: true

module Demo
  class InlineEditsController < ApplicationController
    def show
      @kit = demo_kit
    end

    def update
      value = submitted_value
      respond_to do |format|
        format.turbo_stream do
          html = helpers.tag.p(
            "Saved: #{value}",
            class: "text-sm text-[var(--surface-muted-content-color)]",
            id: "inline-edit-saved-copy"
          )
          render turbo_stream: turbo_stream.update("inline-edit-server-note", html)
        end
        format.html { redirect_to demo_inline_edit_path }
      end
    end

    def fail
      head :unprocessable_entity
    end

    private

    def demo_kit
      OpenStruct.new(
        title: "Summer field kit",
        page_title: "Coast path notes",
        hero_title: "Pack light",
        note: "Leave at dawn. Tide tables in the side pocket. Extra socks.",
        intro_html: "<p>Write as you walk. <strong>Bold the find.</strong> Keep the list short.</p>"
      )
    end

    def submitted_value
      kit = params[:kit]
      if kit.respond_to?(:to_unsafe_h)
        text = kit.to_unsafe_h.values.find { |item| item.is_a?(String) && item.present? }
        return text if text
      elsif kit.respond_to?(:values)
        text = kit.values.find { |item| item.is_a?(String) && item.present? }
        return text if text
      end

      "ok"
    end
  end
end
