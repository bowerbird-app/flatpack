# frozen_string_literal: true

require "cgi"
require "pathname"
require_relative "component_catalog/initialize_kwarg_defaults"
require_relative "component_catalog/doc_examples"

module FlatPack
  module ComponentCatalog
    private_constant :DocExamples

    COMPONENT_ROOT = -> { FlatPack::Engine.root.join("app/components/flat_pack") }

    SKINNY_KEYS = %i[name class description category].freeze

    PATH_GLOBS = [
      "**/component.rb",
      "**/*_component.rb",
      "**/item.rb"
    ].freeze

    EXTRA_RELATIVE_PATHS = [
      "chat/message.rb"
    ].freeze

    PUBLICITY_RULES = [
      {name: :base, if: ->(row) { row[:class] == "FlatPack::BaseComponent" }, keep: false, summary: "FlatPack::BaseComponent"},
      {name: :shared, if: ->(row) { row[:class].start_with?("FlatPack::Shared::") }, keep: false, summary: "FlatPack::Shared::*"},
      {name: :form_field, if: ->(row) { row[:class] == "FlatPack::FormField::Component" }, keep: false, summary: "FlatPack::FormField::Component"},
      {name: :not_a_class, if: ->(row) { !row[:class_object].is_a?(Class) }, keep: false, summary: "non-classes"},
      {name: :not_component, if: ->(row) { !(row[:class_object] < FlatPack::BaseComponent) }, keep: false, summary: "classes that do not inherit FlatPack::BaseComponent"},
      {name: :public, if: ->(_row) { true }, keep: true}
    ].freeze

    ENUM_BINDINGS = [
      {constant: :SCHEMES, kwargs: %i[style]},
      {constant: :STYLES, kwargs: %i[style]},
      {constant: :VARIANTS, kwargs: %i[variant style]},
      {constant: :SIZES, kwargs: %i[size]},
      {constant: :TYPES, kwargs: %i[type]},
      {constant: :ALIGNMENTS, kwargs: %i[alignment]},
      {constant: :DIRECTIONS, kwargs: %i[direction]},
      {constant: :STATES, kwargs: %i[state]},
      {constant: :PLACEMENTS, kwargs: %i[placement]},
      {constant: :SHAPES, kwargs: %i[shape]},
      {constant: :ORIENTATIONS, kwargs: %i[orientation]},
      {constant: :MODES, kwargs: %i[mode]},
      {constant: :STATUSES, kwargs: %i[status]},
      {constant: :GAPS, kwargs: %i[gap]},
      {constant: :COLS, kwargs: %i[cols]},
      {constant: :ALIGNS, kwargs: %i[align]},
      {constant: :SEPARATORS, kwargs: %i[separator]},
      {constant: :PADDINGS, kwargs: %i[padding]},
      {constant: :HOVERS, kwargs: %i[hover]},
      {constant: :TREND_DIRECTIONS, kwargs: %i[trend_direction]},
      {constant: :OVERLAPS, kwargs: %i[overlap]},
      {constant: :LOADING_VARIANTS, kwargs: %i[loading_variant]},
      {constant: :INSERT_MODES, kwargs: %i[insert_mode]},
      {constant: :AVATAR_MODES, kwargs: %i[avatar_mode]}
    ].freeze

    DOC_KEYS = {
      "chart" => "charts",
      "chip" => "chips",
      "chip_group" => "chips",
      "checkbox" => "inputs",
      "date_input" => "inputs",
      "email_input" => "inputs",
      "file_input" => "inputs",
      "number_input" => "inputs",
      "password_input" => "inputs",
      "phone_input" => "inputs",
      "radio_group" => "inputs",
      "search_input" => "inputs",
      "select" => "inputs",
      "switch" => "inputs",
      "text_area" => "inputs",
      "text_input" => "inputs",
      "url_input" => "inputs",
      "comments" => "comments-thread"
    }.freeze

    TYPE_RULES = [
      {if: ->(parameter) { parameter.key?(:enum) }, type: "string"},
      {if: ->(parameter) { parameter[:name] == "system_arguments" }, type: "html"},
      {if: ->(_parameter) { true }, type: "any"}
    ].freeze

    MISSING_DESCRIPTION = "No dedicated documentation available for this component yet."

    class << self
      def list
        records = entries.map { |entry| entry.slice(*SKINNY_KEYS) }
        {
          records: records,
          meta: {
            count: records.size,
            gem_version: FlatPack::VERSION,
            publicity: {
              scope: "public",
              excludes: publicity_excludes
            }
          }
        }
      end

      def show(name)
        entry = find_entry(name)
        return if entry.nil?

        entry.slice(*SKINNY_KEYS).merge(
          parameters: parameters_for(entry[:class_object]),
          slots: slots_for(entry[:class_object]),
          examples: DocExamples.for(entry[:class_object], doc_path_for(entry[:relative_path]))
        )
      end

      def reset!
        @entries = nil
        InitializeKwargDefaults.reset!
        DocExamples.reset!
      end

      def entries
        @entries ||= build_entries
      end

      private

      def build_entries
        enumerate_paths.filter_map { |path| row_from_path(path) }
          .select { |row| public?(row) }
          .sort_by { |row| row[:name] }
      end

      def enumerate_paths
        root = COMPONENT_ROOT.call
        globbed = PATH_GLOBS.flat_map { |pattern| Dir.glob(root.join(pattern)) }
        extras = EXTRA_RELATIVE_PATHS.map { |relative| root.join(relative).to_s }
        (globbed + extras).uniq.sort
      end

      def row_from_path(path)
        relative = Pathname.new(path).relative_path_from(COMPONENT_ROOT.call).to_s
        constant = class_object_for(relative)
        return if constant.nil?

        klass = unwrap_component_module(constant)
        class_name = klass.name
        return if class_name.blank?

        {
          name: class_name.delete_prefix("FlatPack::"),
          class: class_name,
          description: description_for(klass, relative),
          category: category_for(class_name),
          class_object: klass,
          relative_path: relative
        }
      end

      def class_object_for(relative)
        name = "FlatPack::#{relative.delete_suffix(".rb").split("/").map(&:camelize).join("::")}"
        name.safe_constantize
      end

      def unwrap_component_module(constant)
        if constant.is_a?(Module) && !constant.is_a?(Class) && constant.const_defined?(:Component, false)
          return constant.const_get(:Component, false)
        end

        constant
      end

      def public?(row)
        rule = PUBLICITY_RULES.find { |candidate| candidate[:if].call(row) }
        rule.fetch(:keep)
      end

      def publicity_excludes
        PUBLICITY_RULES.filter_map { |rule|
          next if rule.fetch(:keep)

          rule.fetch(:summary)
        }
      end

      def category_for(class_name)
        class_name.delete_prefix("FlatPack::").split("::").first
      end

      def description_for(klass, relative)
        if klass.respond_to?(:catalog_description)
          text = klass.catalog_description
          return text if text.present?
        end

        path = doc_path_for(relative)
        return MISSING_DESCRIPTION if path.nil?

        first_paragraph_from_markdown(path)
      end

      def doc_path_for(relative)
        family = relative.split("/").first
        doc_key = DOC_KEYS.fetch(family, family)
        dash_key = doc_key.tr("_", "-")
        [
          FlatPack::Engine.root.join("docs/components/#{doc_key}.md"),
          FlatPack::Engine.root.join("docs/components/#{dash_key}.md")
        ].find { |candidate| File.exist?(candidate) }
      end

      def first_paragraph_from_markdown(path)
        lines = File.readlines(path, chomp: true)
        in_code_block = false
        paragraph_lines = []

        lines.each do |line|
          stripped = line.strip

          if stripped.start_with?("```")
            in_code_block = !in_code_block
            next
          end

          next if in_code_block
          next if stripped.start_with?("#")
          next if stripped.start_with?("|")

          if stripped.empty?
            break if paragraph_lines.any?
            next
          end

          paragraph_lines << stripped
        end

        paragraph_lines.join(" ").presence || "No description available."
      end

      def find_entry(name)
        needle = canonicalize_name(name)
        entries.find { |entry| entry[:name] == needle || entry[:class] == needle }
      end

      def canonicalize_name(name)
        raw = name.to_s
        raw = CGI.unescape(raw) if raw.include?("%")
        raw.gsub("--", "::").delete_prefix("FlatPack::")
      end

      def parameters_for(klass)
        method = klass.instance_method(:initialize)
        kwargs = method.parameters.filter_map { |kind, pname|
          next if pname.nil?
          next unless kind == :keyreq || kind == :key || kind == :keyrest

          {
            name: ((kind == :keyrest && pname == :system_arguments) ? "system_arguments" : pname.to_s),
            required: kind == :keyreq
          }
        }
        enums = enums_for(klass, kwargs.map { |row| row[:name] })
        defaults = InitializeKwargDefaults.literal_defaults(klass)
        kwargs.map { |row|
          row = row.merge(enum: enums[row[:name]]) if enums[row[:name]]
          row = row.merge(default: defaults[row[:name]]) if defaults.key?(row[:name])
          row.merge(type: type_for(row))
        }
      end

      def slots_for(klass)
        return [] unless klass.respond_to?(:registered_slots)

        klass.registered_slots.map { |registry_name, config|
          {
            name: public_slot_name(klass, registry_name),
            collection: config.fetch(:collection, false)
          }
        }.sort_by { |row| row[:name] }
      end

      def public_slot_name(klass, registry_name)
        name = registry_name.to_s
        return name unless name.end_with?("_slot")

        candidate = name.delete_suffix("_slot")
        return candidate if klass.method_defined?(candidate.to_sym, false)

        name
      end

      def enums_for(klass, kwarg_names)
        bound = {}
        ENUM_BINDINGS.each do |binding|
          next unless klass.const_defined?(binding[:constant], false)

          value = klass.const_get(binding[:constant], false)
          keys = option_keys(value)
          next if keys.empty?

          kwarg = binding[:kwargs].map(&:to_s).find { |candidate| kwarg_names.include?(candidate) }
          next if kwarg.nil?

          bound[kwarg] = keys
        end
        bound
      end

      def option_keys(value)
        case value
        when Hash
          value.keys.map(&:to_s)
        when Array
          return [] unless value.all? { |item| item.is_a?(Symbol) || item.is_a?(String) }

          value.map(&:to_s)
        else
          []
        end
      end

      def type_for(parameter)
        TYPE_RULES.find { |rule| rule[:if].call(parameter) }.fetch(:type)
      end
    end
  end
end
