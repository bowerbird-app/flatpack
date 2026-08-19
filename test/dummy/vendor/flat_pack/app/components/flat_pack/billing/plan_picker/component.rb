# frozen_string_literal: true

module FlatPack
  module Billing
    module PlanPicker
      class Component < FlatPack::BaseComponent
        renders_one :footer

        undef_method :with_footer, :with_footer_content

        def initialize(items: [], **system_arguments)
          super(**system_arguments)
          @items = Array(items).map { |item| normalize_item(item) }
        end

        def footer(*args, **kwargs, &block)
          return get_slot(:footer) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:footer, nil, *args, **kwargs, &block)
        end

        def call
          content_tag(:div, **merge_attributes(class: classes("w-full space-y-4"))) do
            safe_join([
              render_plans_grid,
              render_footer_row
            ].compact)
          end
        end

        private

        def render_plans_grid
          render FlatPack::Grid::Component.new(cols: 3, gap: :md) do
            safe_join(@items.map { |item| render_plan_card(item) })
          end
        end

        def render_plan_card(item)
          card_classes = []
          card_classes << "border-[var(--color-primary)]" if item[:highlighted] || item[:current]

          render FlatPack::Card::Component.new(
            style: :default,
            class: classes(*card_classes)
          ) do |card|
            card.body do
              safe_join([
                render_plan_heading(item),
                render_plan_price(item),
                render_plan_description(item),
                render_plan_features(item)
              ].compact)
            end

            card.footer(divider: true) do
              render_plan_cta(item)
            end
          end
        end

        def render_plan_heading(item)
          content_tag(:div, class: "flex items-start justify-between gap-2 mb-2") do
            safe_join([
              content_tag(:h3, item[:name], class: "text-lg font-semibold text-[var(--surface-content-color)]"),
              render_plan_badges(item)
            ].compact)
          end
        end

        def render_plan_badges(item)
          badges = []
          if item[:highlighted]
            badges << render(FlatPack::Badge::Component.new(text: "Popular", style: :primary, size: :sm))
          end
          if item[:current]
            badges << render(FlatPack::Badge::Component.new(text: "Current", style: :success, size: :sm))
          end
          return nil if badges.empty?

          content_tag(:div, class: "flex flex-wrap gap-1") { safe_join(badges) }
        end

        def render_plan_price(item)
          return nil if item[:price_text].blank?

          content_tag(:p, item[:price_text], class: "text-2xl font-bold text-[var(--surface-content-color)] mb-2")
        end

        def render_plan_description(item)
          return nil if item[:description].blank?

          content_tag(:p, item[:description], class: "text-sm text-[var(--surface-muted-content-color)] mb-3")
        end

        def render_plan_features(item)
          features = Array(item[:features])
          return nil if features.empty?

          content_tag(:ul, class: "mt-3 space-y-2 text-sm text-[var(--surface-content-color)]", role: "list") do
            safe_join(features.map { |feature|
              content_tag(:li, class: "flex items-start gap-2") do
                safe_join([
                  content_tag(:span, class: "mt-0.5 text-[var(--surface-muted-content-color)]") do
                    render FlatPack::Shared::IconComponent.new(name: :check_circle, size: :sm)
                  end,
                  content_tag(:span, feature)
                ])
              end
            })
          end
        end

        def render_plan_cta(item)
          style = item[:current] ? :secondary : :primary
          kwargs = {
            text: item[:cta_text],
            style: style,
            class: "w-full"
          }
          kwargs[:href] = item[:href] if item[:href].present?

          render FlatPack::Button::Component.new(**kwargs)
        end

        def render_footer_row
          return nil unless footer?

          content_tag(:div, footer)
        end

        def normalize_item(item)
          hash = item.respond_to?(:to_h) ? item.to_h : item
          raise ArgumentError, "each plan item must be a Hash" unless hash.is_a?(Hash)

          normalized = hash.transform_keys(&:to_sym)
          raise ArgumentError, "plan item name is required" if normalized[:name].blank?

          {
            name: normalized[:name],
            price_text: normalized[:price_text],
            description: normalized[:description],
            features: Array(normalized[:features]),
            href: sanitize_plan_href(normalized[:href]),
            cta_text: normalized[:cta_text].presence || (normalized[:current] ? "Current plan" : "Get started"),
            current: !!normalized[:current],
            highlighted: !!normalized[:highlighted]
          }
        end

        def sanitize_plan_href(url)
          return nil if url.nil?

          sanitized = FlatPack::AttributeSanitizer.sanitize_url(url)
          return sanitized if sanitized.present? || url.blank?

          raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
        end
      end
    end
  end
end
