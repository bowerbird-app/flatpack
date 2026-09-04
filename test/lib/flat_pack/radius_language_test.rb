# frozen_string_literal: true

require "test_helper"

module FlatPack
  class RadiusLanguageTest < ActiveSupport::TestCase
    test "maps Tailwind scale names onto kit radius tokens" do
      assert_equal "rounded-[var(--radius-sm)]", RadiusLanguage.rewrite("rounded-sm")
      assert_equal "rounded-[var(--radius-md)]", RadiusLanguage.rewrite("rounded-md")
      assert_equal "rounded-[var(--radius-lg)]", RadiusLanguage.rewrite("rounded-lg")
      assert_equal "rounded-[var(--radius-xl)]", RadiusLanguage.rewrite("rounded-xl")
      assert_equal "rounded-[var(--radius-md)]", RadiusLanguage.rewrite("rounded-2xl")
      assert_equal "rounded-[var(--radius-lg)]", RadiusLanguage.rewrite("rounded-3xl")
    end

    test "keeps directional and variant prefixes" do
      assert_equal "rounded-t-[var(--radius-md)]", RadiusLanguage.rewrite("rounded-t-md")
      assert_equal "rounded-l-[var(--radius-md)]", RadiusLanguage.rewrite("rounded-l-md")
      assert_equal "md:rounded-[var(--radius-lg)]", RadiusLanguage.rewrite("md:rounded-lg")
      assert_equal "[&>*:first-child]:rounded-l-[var(--radius-md)]",
        RadiusLanguage.rewrite("[&>*:first-child]:rounded-l-md")
    end

    test "leaves pills, squares, and already-tokenized classes alone" do
      source = "rounded-full rounded-none rounded-l-none rounded-[var(--radius-md)]"

      assert_equal source, RadiusLanguage.rewrite(source)
    end

    test "rewrites Tailwind default fallbacks to kit radius values" do
      source = "border-radius: var(--radius-md, 0.375rem); border-radius: var(--radius-sm, 0.25rem);"

      assert_equal "border-radius: var(--radius-md, 1rem); border-radius: var(--radius-sm, 0.75rem);",
        RadiusLanguage.rewrite(source)
    end

    test "is idempotent including CSS fallbacks" do
      source = "hover:rounded-md rounded-2xl border-radius: var(--radius-md, 0.375rem);"

      assert_equal RadiusLanguage.rewrite(source), RadiusLanguage.rewrite(RadiusLanguage.rewrite(source))
    end

    test "does not rewrite unmapped Tailwind extras" do
      assert_equal "rounded-xs rounded-4xl", RadiusLanguage.rewrite("rounded-xs rounded-4xl")
    end

    test "detects unmapped Tailwind extras and leftover fallbacks" do
      source = %(class: "rounded-xs" border-radius: var(--radius-md, 0.375rem);)

      assert_includes RadiusLanguage.utilities_in(source), "rounded-xs"
      assert_includes RadiusLanguage.utilities_in(source), "var(--radius-md, 0.375rem)"
    end
  end
end
