# frozen_string_literal: true

require "test_helper"

module FlatPack
  module AnimatedCharacter
    class DefinitionTest < ActiveSupport::TestCase
      test "bot and pip are serializable definitions" do
        [AnimatedCharacter.bot, AnimatedCharacter.pip].each do |definition|
          again = Definition.sanitize(definition)

          assert_equal definition, again
          assert_kind_of String, definition.to_json
        end
      end

      test "bot blinks by scaling the eye group" do
        track = AnimatedCharacter.bot.dig("states", "blink", "tracks", 0)

        assert_equal "eyes", track["part"]
        assert_equal "scaleY", track["property"]
        assert_equal [1, 0.08, 1], track["keyframes"]
      end

      test "icon presets are playable definitions" do
        wiggle = Presets.fetch(:wiggle)
        draw = Presets.fetch(:draw)

        assert_equal "rotate", wiggle.dig("states", "play", "tracks", 0, "property")
        assert_equal ["length", 0], draw.dig("states", "play", "tracks", 0, "keyframes")
        assert_equal Presets::NAMES, Presets::DEFINITIONS.keys
      end

      test "rejects an unknown animate name" do
        error = assert_raises(ArgumentError) { Presets.fetch(:bounce) }

        assert_match(/wiggle, pop, draw, spin, nudge/, error.message)
      end

      test "rejects shapes and attributes outside the allowlist" do
        assert_raises(ArgumentError) { Definition.sanitize(scene(shapes: [{type: "script"}])) }
        assert_raises(ArgumentError) do
          Definition.sanitize(scene(shapes: [{type: "circle", cx: 1, cy: 1, r: 1, onclick: "alert(1)"}]))
        end
        assert_raises(ArgumentError) do
          Definition.sanitize(scene(shapes: [{type: "path", d: "M0 0<script>alert(1)</script>"}]))
        end
        assert_raises(ArgumentError) do
          Definition.sanitize(scene(shapes: [{type: "circle", cx: 1, cy: 1, r: 1, fill: "url(#x)"}]))
        end
      end

      test "rejects a track aimed at a missing part or an unknown property" do
        assert_raises(ArgumentError) { Definition.sanitize(scene(part: "nope")) }
        assert_raises(ArgumentError) { Definition.sanitize(scene(property: "d")) }
      end

      test "rejects a duplicate or unsafe part name" do
        raw = scene
        raw[:parts] << {name: "body", shapes: [{type: "circle", cx: 1, cy: 1, r: 1}]}

        assert_raises(ArgumentError) { Definition.sanitize(raw) }
        assert_raises(ArgumentError) { Definition.sanitize(scene(name: "eyes\"><script>")) }
      end

      test "allows a motion-only definition for icon presets" do
        definition = Definition.sanitize(Presets::DEFINITIONS[:spin])

        refute definition.key?("view_box")
        assert_equal "root", definition.dig("states", "play", "tracks", 0, "part")
      end

      private

      def scene(name: "body", shapes: nil, part: "body", property: "translateY", **extra_shape)
        shapes ||= [{type: "circle", cx: 1, cy: 1, r: 1}.merge(extra_shape)]
        {
          view_box: "0 0 10 10",
          parts: [{name: name, shapes: shapes}],
          states: {
            idle: {
              tracks: [
                {part: part, property: property, keyframes: [0, 1], duration: 200}
              ]
            }
          }
        }
      end
    end
  end
end
