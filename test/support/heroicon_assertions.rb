# frozen_string_literal: true

module FlatPack
  module HeroiconAssertions
    def heroicon_inner(name, variant = "outline")
      inner = FlatPack::Heroicons.fetch(variant, name)
      flunk "missing #{variant} heroicon #{name}" if inner.nil?

      inner
    end

    def assert_heroicon(name, variant: "outline", selector: "svg", count: nil, **options)
      matches = heroicon_matches(selector, heroicon_inner(name, variant), **options)
      if count
        assert_equal count, matches.size, "expected #{count} #{variant} #{name} in #{selector}"
      else
        assert_predicate matches, :any?, "expected #{variant} #{name} inside #{selector}"
      end
    end

    def assert_heroicon_html(html, name, variant = "outline")
      assert_includes normalize_svg(html), normalize_svg(heroicon_inner(name, variant)), "#{variant} #{name}"
    end

    def refute_heroicon(name, variant: "outline", selector: "svg", **options)
      matches = heroicon_matches(selector, heroicon_inner(name, variant), **options)
      assert_empty matches, "did not expect #{variant} #{name} inside #{selector}"
    end

    private

    def heroicon_matches(selector, inner, **options)
      expected = normalize_svg(inner)
      heroicon_nodes(selector, **options).select { |node| heroicon_node_html(node).include?(expected) }
    end

    def heroicon_node_html(node)
      html = if node.respond_to?(:native) && node.native.respond_to?(:inner_html)
        node.native.inner_html
      elsif node.respond_to?(:evaluate_script)
        node.evaluate_script("this.innerHTML")
      else
        node.inner_html
      end
      normalize_svg(html)
    end

    def normalize_svg(markup)
      markup.to_s.gsub(%r{<([a-zA-Z0-9:-]+)([^>]*?)/>}, '<\1\2></\1>')
    end

    def heroicon_nodes(selector, **options)
      if heroicon_use_page?
        page.all(selector, **options)
      else
        css_select(selector)
      end
    end

    def heroicon_use_page?
      return true if defined?(ActionDispatch::SystemTestCase) && is_a?(ActionDispatch::SystemTestCase)

      respond_to?(:rendered_content)
    end
  end
end

ActiveSupport::TestCase.include FlatPack::HeroiconAssertions
