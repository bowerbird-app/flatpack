# frozen_string_literal: true

module FlatPack
  module AnimatedCharacter
    class << self
      def bot
        Definition.sanitize(bot_definition)
      end

      def pip
        Definition.sanitize(pip_definition)
      end

      private

      def bot_definition
        {
          view_box: "0 0 64 64",
          parts: [
            {
              name: "body",
              shapes: [
                {type: "rect", x: 14, y: 22, width: 36, height: 30, rx: 14, fill: "currentColor"}
              ],
              parts: [
                antenna_part,
                eyes_part,
                mouth_part("mouth", "M27 44q5 3.5 10 0"),
                mouth_part("smile", "M26 42q6 6 12 0", opacity: 0),
                think_part
              ]
            }
          ],
          states: {
            idle: {tracks: [bob, antenna_sway]},
            blink: {tracks: [blink_track]},
            happy: {tracks: happy_tracks},
            thinking: {tracks: thinking_tracks}
          }
        }
      end

      def pip_definition
        {
          view_box: "0 0 48 48",
          parts: [
            {
              name: "body",
              shapes: [
                {type: "circle", cx: 24, cy: 26, r: 16, fill: "currentColor"}
              ],
              parts: [
                {
                  name: "eyes",
                  shapes: [
                    eye(18, 24, 2.4),
                    eye(30, 24, 2.4)
                  ]
                }
              ]
            }
          ],
          states: {
            idle: {
              tracks: [
                track("body", "translateY", [0, -1.2, 0], duration: 2000, iterations: "infinite"),
                track("eyes", "scaleY", pip_blink_frames, duration: 2600, iterations: "infinite")
              ]
            }
          }
        }
      end

      def antenna_part
        {
          name: "antenna",
          shapes: [
            {type: "line", x1: 32, y1: 22, x2: 32, y2: 10, stroke: "currentColor", "stroke-width": 2.5, "stroke-linecap": "round"},
            {type: "circle", cx: 32, cy: 7, r: 3.5, fill: "currentColor"}
          ]
        }
      end

      def eyes_part
        {
          name: "eyes",
          shapes: [eye(26, 34, 3.3), eye(38, 34, 3.3)]
        }
      end

      def eye(cx, cy, radius)
        {type: "circle", cx: cx, cy: cy, r: radius, fill: "var(--surface-background-color)"}
      end

      def mouth_part(name, path, opacity: nil)
        part = {
          name: name,
          shapes: [
            {
              type: "path",
              d: path,
              fill: "none",
              stroke: "var(--surface-background-color)",
              "stroke-width": 2,
              "stroke-linecap": "round"
            }
          ]
        }
        part[:opacity] = opacity unless opacity.nil?
        part
      end

      def think_part
        {
          name: "think",
          opacity: 0,
          shapes: [
            {type: "circle", cx: 48, cy: 18, r: 1.6, fill: "currentColor"},
            {type: "circle", cx: 53, cy: 14, r: 1.6, fill: "currentColor"},
            {type: "circle", cx: 58, cy: 18, r: 1.6, fill: "currentColor"}
          ]
        }
      end

      def bob
        track("body", "translateY", [0, -1.5, 0], duration: 2200, iterations: "infinite")
      end

      def antenna_sway
        track("antenna", "rotate", [0, 7, 0, -5, 0], duration: 2800, iterations: "infinite")
      end

      def blink_track
        track("eyes", "scaleY", [1, 0.08, 1], duration: 160)
      end

      def happy_tracks
        [
          track("body", "translateY", [0, -3, 0], duration: 420, easing: "enter"),
          track("body", "scaleX", [1, 1.06, 1], duration: 420, easing: "enter"),
          track("body", "scaleY", [1, 1.06, 1], duration: 420, easing: "enter"),
          track("mouth", "opacity", [1, 0], duration: 180),
          track("smile", "opacity", [0, 1], duration: 180)
        ]
      end

      def thinking_tracks
        [
          track("eyes", "translateX", [0, 2.5, 0], duration: 1200, iterations: "infinite"),
          track("antenna", "rotate", [0, 12, -8, 0], duration: 1400, iterations: "infinite"),
          track("think", "opacity", [0, 1], duration: 220, easing: "enter")
        ]
      end

      def pip_blink_frames
        [
          {value: 1, offset: 0},
          {value: 1, offset: 0.42},
          {value: 0.08, offset: 0.5},
          {value: 1, offset: 0.58},
          {value: 1, offset: 1}
        ]
      end

      def track(part, property, keyframes, duration:, iterations: 1, easing: "standard", delay: 0)
        {
          part: part,
          property: property,
          keyframes: keyframes,
          duration: duration,
          delay: delay,
          easing: easing,
          iterations: iterations
        }
      end
    end
  end
end
