# frozen_string_literal: true

module FlatPack
  module Button
    # Real form for a styled control. POST for every verb except GET.
    # _method for put, patch, and delete. CSRF except on GET. data-turbo on the form.
    # Hidden fields sit in a hidden wrapper so display:contents does not turn
    # them into flex items beside the control.
    module FormSubmit
      FORM_METHODS = %i[get post put patch delete].freeze
      UNSAFE_URL = "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."

      class << self
        def normalize_method(method)
          verb = method.nil? ? :post : method.to_sym
          return verb if FORM_METHODS.include?(verb)

          raise ArgumentError, "Invalid method: #{method.inspect}. Must be one of: #{FORM_METHODS.join(", ")}."
        rescue NoMethodError, TypeError
          raise ArgumentError, "Invalid method: #{method.inspect}. Must be one of: #{FORM_METHODS.join(", ")}."
        end

        def validate_turbo!(turbo)
          return if turbo == true || turbo == false

          raise ArgumentError, "Invalid turbo: #{turbo.inspect}. Must be true or false."
        end

        def validate_params!(params, url:)
          return if params.nil?

          unless params.is_a?(Hash)
            raise ArgumentError, "params: must be a Hash."
          end

          return if url.present? || params.empty?

          raise ArgumentError, "params: needs url:."
        end
      end

      def render_submit_form(url:, method:, params:, turbo:)
        verb = method.nil? ? :post : method.to_sym
        content_tag(:form, **submit_form_attributes(url: url, method: verb, turbo: turbo)) do
          safe_join([
            content_tag(:div, safe_join(submit_form_hidden_fields(method: verb, params: params)), hidden: true),
            yield
          ])
        end
      end

      private

      def submit_form_attributes(url:, method:, turbo:)
        {
          action: url,
          method: (method == :get) ? "get" : "post",
          "accept-charset": "UTF-8",
          class: "contents",
          data: {turbo: turbo}
        }
      end

      def submit_form_hidden_fields(method:, params:)
        [
          submit_form_method_field(method),
          submit_form_authenticity_field(method),
          submit_form_param_fields(params)
        ].compact
      end

      def submit_form_method_field(method)
        return if method == :get || method == :post

        tag.input(type: "hidden", name: "_method", value: method, autocomplete: "off")
      end

      def submit_form_authenticity_field(method)
        return if method == :get

        token = submit_form_authenticity_token
        return if token.blank?

        tag.input(type: "hidden", name: "authenticity_token", value: token, autocomplete: "off")
      end

      def submit_form_authenticity_token
        return unless helpers.respond_to?(:form_authenticity_token)

        helpers.form_authenticity_token
      rescue ArgumentError, NoMethodError, ViewComponent::HelpersCalledBeforeRenderError
        nil
      end

      def submit_form_param_fields(params)
        return if params.blank?

        safe_join(submit_form_flatten_params(params).map { |name, value|
          tag.input(type: "hidden", name: name, value: value, autocomplete: "off")
        })
      end

      def submit_form_flatten_params(pairs, prefix = nil)
        pairs.flat_map do |key, value|
          name = prefix ? "#{prefix}[#{key}]" : key.to_s
          case value
          when Hash
            submit_form_flatten_params(value, name)
          when Array
            value.flat_map do |item|
              if item.is_a?(Hash)
                submit_form_flatten_params(item, "#{name}[]")
              else
                [["#{name}[]", item]]
              end
            end
          else
            [[name, value]]
          end
        end
      end
    end
  end
end
