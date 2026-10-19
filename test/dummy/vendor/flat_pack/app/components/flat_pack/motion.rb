# frozen_string_literal: true

module FlatPack
  # Shared reveal attributes. Box variants can sit on any component root.
  # Words and lines are rendered by FlatPack::Reveal::Component, which splits the text.
  module Motion
    REVEALS = %i[fade rise blur scale wipe zoom words lines].freeze
    BOX_REVEALS = %i[fade rise blur scale wipe zoom].freeze
    TEXT_REVEALS = %i[words lines].freeze
    MEDIA_REVEALS = %i[wipe zoom].freeze
    TAGS = %i[div span p h1 h2 h3 h4 h5 h6 blockquote li].freeze
    DELAYS = %i[sm md lg].freeze
    DURATIONS = %i[fast base slow slower].freeze
    STAGGERS = %i[sm md lg].freeze

    class << self
      def attributes(reveal:, stagger: false, parallax: false, intensity: nil, delay: nil, duration: nil, text: false)
        variant = reveal!(reveal, text: text)
        step = stagger!(stagger)
        parallax = boolean!(parallax, :parallax)

        if parallax && !MEDIA_REVEALS.include?(variant)
          raise ArgumentError, "parallax: true works with reveal: :wipe or :zoom"
        end

        classes = ["fp-reveal", "fp-reveal--#{variant}"]
        classes << "fp-reveal--strong" if strong!(intensity)
        box_stagger = step[:on] && !TEXT_REVEALS.include?(variant)
        classes << "fp-reveal--stagger" if box_stagger
        classes << "fp-reveal--parallax" if parallax

        data = {controller: "flat-pack--reveal"}
        data[:flat_pack__reveal_stagger_value] = true if box_stagger

        result = {class: classes.join(" "), data: data}
        style = timing_style(delay: delay, duration: duration, stagger: step[:css])
        result[:style] = style if style
        result
      end

      def boolean!(value, name)
        return value if value == true || value == false

        raise ArgumentError, "#{name} must be true or false"
      end

      def strong!(intensity)
        return false if intensity.nil?

        return true if intensity.to_sym == :strong

        raise ArgumentError, "Invalid intensity: #{intensity}. Must be :strong"
      end

      private

      def reveal!(reveal, text:)
        if reveal.nil? || reveal.to_s.strip.empty?
          raise ArgumentError, "reveal is required"
        end

        variant = reveal.to_sym
        unless REVEALS.include?(variant)
          raise ArgumentError, "Invalid reveal: #{reveal}. Must be one of: #{REVEALS.join(", ")}"
        end

        if TEXT_REVEALS.include?(variant) && !text
          raise ArgumentError, "Pass reveal: :#{variant} to FlatPack::Reveal::Component"
        end

        variant
      end

      def stagger!(value)
        return {on: false, css: nil} if value == false || value.nil?
        return {on: true, css: nil} if value == true

        {
          on: true,
          css: instance_time(value, steps: STAGGERS, name: :stagger, prefix: "--motion-stagger", extra: "true, false")
        }
      end

      def timing_style(delay:, duration:, stagger:)
        parts = []
        delay_css = instance_time(delay, steps: DELAYS, name: :delay, prefix: "--motion-delay")
        duration_css = instance_time(duration, steps: DURATIONS, name: :duration, prefix: "--motion-duration")
        parts << "--reveal-delay: #{delay_css}" if delay_css
        parts << "--reveal-duration: #{duration_css}" if duration_css
        parts << "--reveal-stagger: #{stagger}" if stagger
        return nil if parts.empty?

        parts.join("; ")
      end

      def instance_time(value, steps:, name:, prefix:, extra: nil)
        return nil if value.nil?
        return "#{value}ms" if value.is_a?(Integer) && value >= 0

        if (value.is_a?(Symbol) || value.is_a?(String)) && steps.include?(value.to_sym)
          return "var(#{prefix}-#{value.to_sym})"
        end

        allowed = [extra, steps.map { |step| ":#{step}" }.join(", "), "or a number of milliseconds"].compact
        raise ArgumentError, "Invalid #{name}: #{value}. Must be #{allowed.join(", ")}"
      end
    end
  end
end
