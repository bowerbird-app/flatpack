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

    class << self
      def attributes(reveal:, stagger: false, parallax: false, intensity: nil, text: false)
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

        stagger = boolean!(stagger, :stagger)
        parallax = boolean!(parallax, :parallax)

        if parallax && !MEDIA_REVEALS.include?(variant)
          raise ArgumentError, "parallax: true works with reveal: :wipe or :zoom"
        end

        classes = ["fp-reveal", "fp-reveal--#{variant}"]
        classes << "fp-reveal--strong" if strong!(intensity)
        classes << "fp-reveal--stagger" if stagger && !TEXT_REVEALS.include?(variant)
        classes << "fp-reveal--parallax" if parallax

        data = {controller: "flat-pack--reveal"}
        if stagger && !TEXT_REVEALS.include?(variant)
          data[:flat_pack__reveal_stagger_value] = true
        end

        {class: classes.join(" "), data: data}
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
    end
  end
end
