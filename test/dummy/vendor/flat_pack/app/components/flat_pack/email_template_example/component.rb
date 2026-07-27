# frozen_string_literal: true

module FlatPack
  module EmailTemplateExample
    class Component < FlatPack::BaseComponent
      def call
        render FlatPack::EmailCard::Component.new do
          safe_join([
            heading,
            intro,
            render_primary_button,
            spacer,
            render_secondary_button,
            footer_spacer,
            render_footer_links
          ])
        end
      end

      private

      def heading
        content_tag(:h1, "Action required", style: "margin:0 0 12px 0;font-family:Arial,sans-serif;font-size:24px;line-height:1.3;color:#111827;")
      end

      def intro
        content_tag(:p, "Please confirm your account details to continue securely.", style: "margin:0 0 16px 0;font-family:Arial,sans-serif;font-size:16px;line-height:1.5;color:#374151;")
      end

      def render_primary_button
        render FlatPack::EmailButton::Component.new(
          href: "https://example.com/confirm",
          label: "Confirm details",
          variant: :primary,
          full_width: true
        )
      end

      def render_secondary_button
        render FlatPack::EmailButton::Component.new(
          href: "https://example.com/settings",
          label: "Review settings",
          variant: :secondary,
          full_width: true
        )
      end

      def render_footer_links
        render FlatPack::EmailFooterLinks::Component.new(
          links: [
            {label: "Privacy", href: "https://example.com/privacy"},
            {label: "Terms", href: "https://example.com/terms"},
            {label: "Unsubscribe", href: "https://example.com/unsubscribe"},
            {label: "Help", href: "https://example.com/help"}
          ],
          color: "#6b7280",
          font_size: "12px"
        )
      end

      def spacer
        content_tag(:div, nil, style: "height:12px;line-height:12px;font-size:12px;")
      end

      def footer_spacer
        content_tag(:div, nil, style: "height:20px;line-height:20px;font-size:20px;")
      end
    end
  end
end
