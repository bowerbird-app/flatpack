# frozen_string_literal: true

require "test_helper"

module FlatPack
  module AnimatedCharacter
    class ComponentTest < ViewComponent::TestCase
      test "renders nested parts and the idle state" do
        render_inline(Component.new(definition: AnimatedCharacter.bot, state: :idle, size: :xl, label: "Flatpack bot"))

        assert_selector "svg.fp-animated-character.w-40.h-40[viewbox='0 0 64 64']"
        assert_selector "svg[role='img'][aria-label='Flatpack bot']"
        assert_selector "svg[data-controller='flat-pack--svg-motion']"
        assert_selector "svg[data-flat-pack--svg-motion-state-value='idle']"
        assert_selector "svg[data-flat-pack--svg-motion-trigger-value='mount']"
        assert_selector "g[data-part='body'] g[data-part='eyes'] circle", count: 2
        assert_selector "g[data-part='antenna']"
        assert_selector "g[data-part='smile'][opacity='0']"
        refute_selector "svg[aria-hidden]"
        refute_includes rendered_content, "<script"
        refute_includes rendered_content, "onload"
      end

      test "hides a character with no label" do
        render_inline(Component.new(definition: AnimatedCharacter.pip, label: nil))

        assert_selector "svg[aria-hidden='true']"
        refute_selector "svg[role='img']"
        refute_selector "svg[aria-label]"
      end

      test "rejects an unknown size or state" do
        assert_raises(ArgumentError) do
          Component.new(definition: AnimatedCharacter.bot, size: :huge)
        end
        assert_raises(ArgumentError) do
          Component.new(definition: AnimatedCharacter.bot, state: :sleeping)
        end
      end

      test "does not render a raw svg string" do
        raw = AnimatedCharacter.bot.merge("parts" => [{"name" => "body", "shapes" => [{"type" => "rect", "html" => "<svg>"}]}])

        assert_raises(ArgumentError) { Component.new(definition: raw) }
      end
    end
  end
end
