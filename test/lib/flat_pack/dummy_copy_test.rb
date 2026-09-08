# frozen_string_literal: true

require "test_helper"

module FlatPack
  class DummyCopyTest < ActiveSupport::TestCase
    test "dummy sample copy does not use backend or kit jargon" do
      files = [
        "test/dummy/app/views/pages/hero.html.erb",
        "test/dummy/app/views/pages/hero_centered.html.erb",
        "test/dummy/app/views/pages/collapse.html.erb",
        "test/dummy/app/views/pages/chat_layout.html.erb",
        "test/dummy/app/views/pages/alerts.html.erb",
        "test/dummy/app/views/pages/buttons_pills.html.erb",
        "test/dummy/app/views/pages/popovers.html.erb",
        "test/dummy/app/views/pages/tooltips.html.erb",
        "test/dummy/app/views/pages/page_nav.html.erb",
        "test/dummy/app/views/pages/picker.html.erb"
      ]

      leaks = []
      forbidden = [
        "ViewComponent",
        "Pure Stimulus",
        "Stimulus controller",
        "Panel slot content",
        "treats folders as records"
      ]

      files.each do |relative|
        contents = FlatPack::Engine.root.join(relative).read
        forbidden.each do |phrase|
          next unless contents.include?(phrase)

          leaks << "#{relative}: #{phrase}"
        end
      end

      assert_empty leaks, -> { "Developer wording in dummy copy:\n#{leaks.join("\n")}" }
    end
  end
end
