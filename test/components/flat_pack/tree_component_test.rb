# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Tree
    class ComponentTest < ViewComponent::TestCase
      def test_renders_tree_with_nested_branches_and_leaves
        render_inline(Component.new) do |tree|
          tree.node(label: "src", expanded: true) do |src|
            src.node(label: "components", expanded: true) do |components|
              components.node(label: "Button.tsx")
            end
          end

          tree.node(label: "package.json", active: true)
        end

        assert_selector "div[role='tree']"
        assert_selector "summary[role='treeitem']", text: "src"
        assert_selector "div[role='group']"
        assert_selector "div[role='treeitem']", text: "Button.tsx"
        assert_selector "div[role='treeitem'][aria-selected='true']", text: "package.json"
      end

      def test_renders_links_for_leaf_nodes
        render_inline(Component.new) do |tree|
          tree.node(label: "README.md", href: "/demo/tree")
        end

        assert_selector "a[href='/demo/tree']", text: "README.md"
        assert_includes page.native.to_html, 'class="flex min-w-0 flex-1 items-center gap-1.5"'
      end

      def test_allows_custom_icon_and_meta
        render_inline(Component.new) do |tree|
          tree.node(label: "app", icon: "code-bracket-square", meta: "12 files")
        end

        assert_includes page.native.to_html, "code-bracket-square"
        assert_text "12 files"
      end

      def test_raises_error_for_unsafe_href
        assert_raises ArgumentError do
          render_inline(Component.new) do |tree|
            tree.node(label: "Bad", href: "javascript:alert('xss')")
          end
        end
      end

      def test_merges_custom_container_classes
        render_inline(Component.new(class: "tree-shell"))

        assert_selector "div.tree-shell[role='tree']"
      end
    end
  end
end
