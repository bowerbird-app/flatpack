# frozen_string_literal: true

module FlatPack
  module ComponentCatalog
    module InitializeKwargDefaults
      class << self
        def literal_defaults(klass)
          path, lineno = initialize_location(klass)
          return {} if path.nil?

          cache[cache_key(path, lineno)] ||= extract_from_file(path, lineno)
        end

        def reset!
          @cache = nil
        end

        private

        def cache
          @cache ||= {}
        end

        def cache_key(path, lineno)
          [File.expand_path(path), lineno]
        end

        def initialize_location(klass)
          return unless klass.respond_to?(:instance_method)

          method = klass.instance_method(:initialize)
          path, lineno = method.source_location
          return if path.nil? || lineno.nil?
          return unless File.file?(path) && File.readable?(path)

          [path, lineno]
        rescue NameError
          nil
        end

        def extract_from_file(path, lineno)
          return {} unless defined?(RubyVM::AbstractSyntaxTree)

          root = RubyVM::AbstractSyntaxTree.parse_file(path)
          definition = find_initialize(root, lineno)
          return {} if definition.nil?

          args = args_node(definition)
          return {} if args.nil?

          defaults_from_args(args)
        rescue SyntaxError, SystemCallError, EncodingError
          {}
        end

        def find_initialize(node, lineno)
          return unless ast_node?(node)

          if node.type == :DEFN && node.children[0] == :initialize && node.first_lineno == lineno
            return node
          end

          node.children.each do |child|
            found = find_initialize(child, lineno)
            return found if found
          end
          nil
        end

        def args_node(definition)
          scope = definition.children[1]
          return unless ast_node?(scope) && scope.type == :SCOPE

          scope.children.find { |child| ast_node?(child) && child.type == :ARGS }
        end

        def defaults_from_args(args)
          defaults = {}
          kw = args.children.find { |child| ast_node?(child) && child.type == :KW_ARG }
          each_kw_assignment(kw) do |name, value_node|
            known, value = literal_from(value_node)
            defaults[name] = value if known
          end
          defaults
        end

        def each_kw_assignment(node)
          current = node
          while ast_node?(current) && current.type == :KW_ARG
            assignment, nxt = current.children
            if ast_node?(assignment) && assignment.type == :LASGN
              name = assignment.children[0]
              yield name.to_s, assignment.children[1] if name
            end
            current = nxt
          end
        end

        def literal_from(node)
          return [false, nil] unless ast_node?(node)

          case node.type
          when :NIL
            [true, nil]
          when :TRUE
            [true, true]
          when :FALSE
            [true, false]
          when :STR
            [true, node.children[0]]
          when :LIT, :INTEGER, :FLOAT
            json_safe_lit(node.children[0])
          else
            [false, nil]
          end
        end

        def json_safe_lit(value)
          case value
          when Symbol
            [true, value.to_s]
          when Integer
            [true, value]
          when Float
            value.finite? ? [true, value] : [false, nil]
          else
            [false, nil]
          end
        end

        def ast_node?(value)
          value.is_a?(RubyVM::AbstractSyntaxTree::Node)
        end
      end
    end

    private_constant :InitializeKwargDefaults
  end
end
