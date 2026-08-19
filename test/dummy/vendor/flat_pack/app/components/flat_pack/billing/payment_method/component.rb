# frozen_string_literal: true

module FlatPack
  module Billing
    module PaymentMethod
      class Component < FlatPack::BaseComponent
        renders_one :actions

        undef_method :with_actions, :with_actions_content

        def initialize(
          brand: nil,
          last4: nil,
          expires_text: nil,
          expires_on: nil,
          title: "Payment method",
          empty_title: "No card on file",
          empty_description: "Add a payment method to keep billing up to date.",
          **system_arguments
        )
          super(**system_arguments)
          @brand = brand
          @last4 = last4
          @expires_text = expires_text.presence || expires_on
          @title = title
          @empty_title = empty_title
          @empty_description = empty_description
        end

        def actions(*args, **kwargs, &block)
          return get_slot(:actions) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:actions, nil, *args, **kwargs, &block)
        end

        def call
          content_tag(:div, **merge_attributes(class: classes("w-full"))) do
            render FlatPack::Card::Component.new(style: :default) do |card|
              card.body do
                if filled?
                  render_filled_body
                else
                  render_empty_body
                end
              end
            end
          end
        end

        private

        def filled?
          @brand.present? && @last4.present?
        end

        def render_filled_body
          safe_join([
            content_tag(:h3, @title, class: "text-lg font-semibold text-[var(--surface-content-color)] mb-3"),
            content_tag(:p, "#{@brand} •••• #{@last4}", class: "text-base text-[var(--surface-content-color)] mb-1"),
            (@expires_text.present? ? content_tag(:p, "Expires #{@expires_text}", class: "text-sm text-[var(--surface-muted-content-color)] mb-4") : nil),
            render_actions_row
          ].compact)
        end

        def render_empty_body
          safe_join([
            render(FlatPack::EmptyState::Component.new(
              title: @empty_title,
              description: @empty_description,
              icon: :inbox
            )),
            render_actions_row
          ].compact)
        end

        def render_actions_row
          return nil unless actions?

          content_tag(:div, actions, class: "flex flex-wrap gap-2 mt-2")
        end
      end
    end
  end
end
