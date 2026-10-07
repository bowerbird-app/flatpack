# frozen_string_literal: true

# Optional host gem: dummy demonstrates locale switching. The FlatPack gem itself
# ships only English under `flatpack.*`. Dummy owns French and the language list.
return unless defined?(RecordingStudioInternationalization)

RecordingStudioInternationalization.configure do |config|
  config.available_locales = {
    en: {name: "English"},
    fr: {name: "Français"}
  }
  config.default_locale = :en
end
