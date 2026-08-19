# frozen_string_literal: true

module FlatPack
  module Billing
    module InvoiceList
      class Component < FlatPack::BaseComponent
        renders_one :actions

        undef_method :with_actions, :with_actions_content

        STATUS_BADGES = {
          paid: {text: "Paid", style: :success},
          open: {text: "Open", style: :info},
          failed: {text: "Failed", style: :danger},
          void: {text: "Void", style: :default}
        }.freeze

        def initialize(
          items: [],
          title: "Invoices",
          empty_title: "No invoices yet",
          empty_description: "They’ll show up here after your first payment.",
          pagy: nil,
          **system_arguments
        )
          super(**system_arguments)
          @items = Array(items).map { |item| normalize_item(item) }
          @title = title
          @empty_title = empty_title
          @empty_description = empty_description
          @pagy = pagy
        end

        def actions(*args, **kwargs, &block)
          return get_slot(:actions) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:actions, nil, *args, **kwargs, &block)
        end

        def call
          content_tag(:div, **merge_attributes(class: classes("w-full space-y-4"))) do
            safe_join([
              render_header,
              render_body,
              render_pagination
            ].compact)
          end
        end

        private

        def render_header
          return nil if @title.blank? && !actions?

          content_tag(:div, class: "flex items-center justify-between gap-3") do
            safe_join([
              (@title.present? ? content_tag(:h3, @title, class: "text-lg font-semibold text-[var(--surface-content-color)]") : nil),
              (actions? ? content_tag(:div, actions, class: "flex flex-wrap gap-2") : nil)
            ].compact)
          end
        end

        def render_body
          return render_empty if @items.empty?

          render FlatPack::Table::Component.new(data: @items) do |table|
            table.column(title: "Date", html: ->(item) { item[:date] })
            table.column(title: "Amount", html: ->(item) { item[:amount] })
            table.column(title: "Status", html: ->(item) {
              badge = status_badge(item[:status])
              render FlatPack::Badge::Component.new(text: badge[:text], style: badge[:style], size: :sm)
            })
            table.column(title: "Actions", html: ->(item) {
              if item[:href].blank?
                ""
              else
                render FlatPack::Button::Component.new(
                  text: "Download",
                  href: item[:href],
                  style: :ghost,
                  size: :sm
                )
              end
            })
          end
        end

        def render_empty
          render FlatPack::EmptyState::Component.new(
            title: @empty_title,
            description: @empty_description,
            icon: :inbox
          )
        end

        def render_pagination
          return nil if @pagy.nil?

          render FlatPack::Pagination::Component.new(pagy: @pagy)
        end

        def status_badge(status)
          key = status.to_s.downcase.to_sym
          STATUS_BADGES.fetch(key) do
            {
              text: status.to_s.tr("_", " ").split.map(&:capitalize).join(" "),
              style: :default
            }
          end
        end

        def normalize_item(item)
          hash = item.respond_to?(:to_h) ? item.to_h : item
          raise ArgumentError, "each invoice item must be a Hash" unless hash.is_a?(Hash)

          normalized = hash.transform_keys(&:to_sym)
          raise ArgumentError, "invoice item date is required" if normalized[:date].blank?
          raise ArgumentError, "invoice item amount is required" if normalized[:amount].blank?
          raise ArgumentError, "invoice item status is required" if normalized[:status].blank?

          {
            id: normalized[:id],
            date: normalized[:date],
            amount: normalized[:amount],
            status: normalized[:status],
            href: sanitize_invoice_href(normalized[:href])
          }
        end

        def sanitize_invoice_href(url)
          return nil if url.nil?

          sanitized = FlatPack::AttributeSanitizer.sanitize_url(url)
          return sanitized if sanitized.present? || url.blank?

          raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
        end
      end
    end
  end
end
