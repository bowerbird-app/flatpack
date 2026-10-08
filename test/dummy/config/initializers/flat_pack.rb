# frozen_string_literal: true

FlatPack.configure do |config|
  config.default_icon_variant = :outline
end

# Example host colourway. Colours live in application.tailwind.css, not the theme.
# to_prepare re-registers after autoload in development.
Rails.application.config.to_prepare do
  FlatPack::Button.register_style(:partner, press: :raised)
end
