# frozen_string_literal: true

module FlatPack
  module AnimatedCharacter
    # Icon micro-motions. Each one is a definition the character controller
    # already knows how to play. `root` is the icon svg. `strokes` is every
    # drawn shape inside it, used by the check mark.
    module Presets
      NAMES = %i[wiggle pop draw spin nudge].freeze
      TRIGGERS = %i[hover click mount].freeze

      DEFINITIONS = {
        wiggle: {
          parts: [],
          states: {
            play: {
              tracks: [
                {part: "root", property: "rotate", keyframes: [0, -14, 10, -6, 3, 0], duration: 480, easing: "standard"}
              ]
            }
          }
        },
        pop: {
          parts: [],
          states: {
            play: {
              tracks: [
                {part: "root", property: "scaleX", keyframes: [1, 1.18, 0.96, 1], duration: "base", easing: "enter"},
                {part: "root", property: "scaleY", keyframes: [1, 1.18, 0.96, 1], duration: "base", easing: "enter"}
              ]
            }
          }
        },
        draw: {
          parts: [],
          states: {
            play: {
              tracks: [
                {part: "strokes", property: "strokeDashoffset", keyframes: ["length", 0], duration: 500, easing: "enter"}
              ]
            }
          }
        },
        spin: {
          parts: [],
          states: {
            play: {
              tracks: [
                {part: "root", property: "rotate", keyframes: [0, 360], duration: 600, easing: "standard"}
              ]
            }
          }
        },
        nudge: {
          parts: [],
          states: {
            play: {
              tracks: [
                {part: "root", property: "translateX", keyframes: [0, 4, 0], duration: "base", easing: "standard"}
              ]
            }
          }
        }
      }.freeze

      class << self
        def fetch(name)
          key = name.to_sym
          raw = DEFINITIONS[key]
          raise ArgumentError, "Unknown animate #{name.inspect}. Must be one of: #{NAMES.join(", ")}" unless raw

          Definition.sanitize(raw)
        end
      end
    end
  end
end
