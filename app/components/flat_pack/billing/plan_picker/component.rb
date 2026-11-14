# frozen_string_literal: true

module FlatPack
  module Billing
    module PlanPicker
      class Component < FlatPack::BaseComponent
        class PlanFooter < ViewComponent::Base
          attr_reader :name

          def initialize(name:)
            @name = name.to_s
          end

          def call
            content
          end
        end

        renders_one :footer
        renders_many :plan_footer_slot, PlanFooter

        undef_method :with_footer, :with_footer_content
        undef_method :with_plan_footer_slot, :with_plan_footer_slot_content

        # Same presets as Grid. The number is the column count at the widest breakpoint.
        COLS = FlatPack::Grid::Component::COLUMN_PRESETS
        # Same scale as Card. Body and footer both use it.
        PADDINGS = FlatPack::Card::Component::PADDINGS

        def initialize(items: [], cols: 3, padding: :md, **system_arguments)
          super(**system_arguments)
          @cols = cols.is_a?(Symbol) ? cols : cols.to_i
          @padding = padding.to_sym
          @items = Array(items).map { |item| normalize_item(item) }

          validate_cols!
          validate_padding!
        end

        def footer(*args, **kwargs, &block)
          return get_slot(:footer) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:footer, nil, *args, **kwargs, &block)
        end

        def plan_footer(name: nil, &block)
          return get_slot(:plan_footer_slot) if name.nil? && !block

          raise ArgumentError, "plan_footer name is required" if name.blank?

          set_slot(:plan_footer_slot, nil, name: name, &block)
        end

        def call
          validate_plan_footers!

          content_tag(:div, **merge_attributes(class: classes("w-full space-y-4"))) do
            safe_join([
              render_plans_grid,
              render_footer_row
            ].compact)
          end
        end

        private

        def render_plans_grid
          render FlatPack::Grid::Component.new(cols: @cols, gap: :md) do
            safe_join(@items.map { |item| render_plan_card(item) })
          end
        end

        def render_plan_card(item)
          card_classes = []
          card_classes << "border-[var(--color-primary)]" if item[:highlighted] || item[:current]

          render FlatPack::Card::Component.new(
            background: :default,
            padding: @padding,
            class: classes(*card_classes)
          ) do |card|
            card.body(padding: @padding) do
              safe_join([
                render_plan_heading(item),
                render_plan_price(item),
                render_plan_description(item),
                render_plan_features(item)
              ].compact)
            end

            card.footer(divider: true, padding: @padding) do
              render_plan_action(item)
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
            badges << render(FlatPack::Badge::Component.new(text: fp_t("billing.plan_picker.popular"), style: :primary, size: :sm))
          end
          if item[:current]
            badges << render(FlatPack::Badge::Component.new(text: fp_t("billing.plan_picker.current"), style: :success, size: :sm))
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

        def render_plan_action(item)
          custom = plan_footer_for(item)
          # Slot#to_s renders the block. Stringify here so the card footer
          # capture keeps the HTML instead of dropping a non-String return.
          return custom.to_s.html_safe if custom

          render_plan_cta(item)
        end

        def render_plan_cta(item)
          style = item[:current] ? :secondary : :primary
          kwargs = {
            text: item[:cta_text],
            style: style,
            class: "w-full"
          }

          if item[:url].present?
            kwargs[:url] = item[:url]
            kwargs[:method] = item[:method] if item[:method]
            kwargs[:params] = item[:params] if item[:params]
            kwargs[:turbo] = item[:turbo] if item.key?(:turbo)
          elsif item[:href].present?
            kwargs[:href] = item[:href]
            kwargs[:method] = item[:method] if item[:method]
          end

          render FlatPack::Button::Component.new(**kwargs)
        end

        def plan_footer_for(item)
          return unless plan_footer_slot?

          plan_footer_slot.find { |footer| footer.name == item[:name].to_s }
        end

        def render_footer_row
          return nil unless footer?

          content_tag(:div, footer)
        end

        def validate_plan_footers!
          return unless plan_footer_slot?

          names = @items.map { |item| item[:name].to_s }
          seen = {}
          plan_footer_slot.each do |footer|
            key = footer.name
            raise ArgumentError, "plan_footer name is required" if key.blank?

            if seen[key]
              raise ArgumentError, "plan_footer name #{key.inspect} is already set"
            end

            seen[key] = true
            matches = names.count { |name| name == key }
            if matches.zero?
              raise ArgumentError, "Unknown plan_footer name: #{key.inspect}"
            end
            if matches > 1
              raise ArgumentError, "plan_footer name #{key.inspect} matches more than one plan"
            end
          end
        end

        def validate_cols!
          return if COLS.key?(@cols)

          raise ArgumentError, "Invalid cols: #{@cols}. Must be one of: #{COLS.keys.join(", ")}"
        end

        def validate_padding!
          return if PADDINGS.key?(@padding)

          raise ArgumentError, "Invalid padding: #{@padding}. Must be one of: #{PADDINGS.keys.join(", ")}"
        end

        def normalize_item(item)
          hash = item.respond_to?(:to_h) ? item.to_h : item
          raise ArgumentError, "each plan item must be a Hash" unless hash.is_a?(Hash)

          normalized = hash.transform_keys(&:to_sym)
          raise ArgumentError, "plan item name is required" if normalized[:name].blank?

          href = normalized[:href]
          url = normalized[:url]
          if href.present? && url.present?
            raise ArgumentError, "Pass href: or url:, not both. href: navigates. url: submits a form."
          end

          params = normalized[:params]
          unless params.nil? || params.is_a?(Hash)
            raise ArgumentError, "params: must be a Hash."
          end
          if params.present? && url.blank?
            raise ArgumentError, "params: needs url:."
          end

          if normalized.key?(:turbo) && ![true, false].include?(normalized[:turbo])
            raise ArgumentError, "Invalid turbo: #{normalized[:turbo].inspect}. Must be true or false."
          end

          method = form_method(normalized[:method]) if url.present? && !normalized[:method].nil?

          normalized_item = {
            name: normalized[:name],
            price_text: normalized[:price_text],
            description: normalized[:description],
            features: Array(normalized[:features]),
            href: sanitize_plan_target(href),
            url: sanitize_plan_target(url),
            cta_text: normalized[:cta_text].presence || (normalized[:current] ? fp_t("billing.plan_picker.current_plan") : fp_t("billing.plan_picker.get_started")),
            current: !!normalized[:current],
            highlighted: !!normalized[:highlighted]
          }
          normalized_item[:method] = method if url.present? && !normalized[:method].nil?
          normalized_item[:method] = normalized[:method] if url.blank? && normalized[:method].present?
          normalized_item[:params] = params if params.present?
          normalized_item[:turbo] = normalized[:turbo] if normalized.key?(:turbo)
          normalized_item
        end

        def form_method(method)
          verb = method.to_sym
          return verb if FlatPack::Button::Component::FORM_METHODS.include?(verb)

          raise ArgumentError, "Invalid method: #{method.inspect}. Must be one of: #{FlatPack::Button::Component::FORM_METHODS.join(", ")}."
        rescue NoMethodError, TypeError
          raise ArgumentError, "Invalid method: #{method.inspect}. Must be one of: #{FlatPack::Button::Component::FORM_METHODS.join(", ")}."
        end

        def sanitize_plan_target(url)
          return nil if url.blank?

          sanitized = FlatPack::AttributeSanitizer.sanitize_url(url)
          return sanitized if sanitized.present?

          raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
        end
      end
    end
  end
end
