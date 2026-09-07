# frozen_string_literal: true

require "test_helper"

module FlatPack
  class HeroCardGradientsTest < ActiveSupport::TestCase
    test "kit themes do not ship decorative gradient tokens or helpers" do
      variables = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      refute_match(/--gradient-[1-4]/, variables)
      refute_includes application, ".fp-gradient-1"
      refute_includes application, ".fp-gradient-2"
      refute_includes application, ".fp-gradient-3"
      refute_includes application, ".fp-gradient-4"
    end

    test "hero tagline and card stat labels stay sentence case" do
      hero = FlatPack::Engine.root.join("app/components/flat_pack/hero/component.rb").read
      stat = FlatPack::Engine.root.join("app/components/flat_pack/card/stat/component.rb").read

      refute_includes hero, "uppercase"
      refute_includes hero, "tracking-widest"
      refute_includes stat, "uppercase"
      refute_includes stat, "tracking-wide"
    end

    test "dummy heroes and composed cards do not paint decorative gradient washes" do
      dummy = FlatPack::Engine.root.join("test/dummy")
      hero_pages = Dir[dummy.join("app/views/pages/hero*.html.erb")]
      composed = dummy.join("app/views/pages/cards_composed.html.erb").read
      media = dummy.join("app/views/pages/cards_media.html.erb").read
      styles = dummy.join("app/views/pages/cards_styles.html.erb").read
      showcase = dummy.join("app/views/themes/_demo_showcase.html.erb").read

      assert_operator hero_pages.size, :>=, 4
      hero_pages.each do |path|
        refute_includes File.read(path), "linear-gradient", path
      end
      refute_includes composed, "bg-gradient-to-br"
      refute_includes media, "bg-gradient-to-br"
      refute_includes styles, "bg-gradient-to-br"
      refute_includes composed, "uppercase tracking"
      refute_includes composed, "Wise-style promo"
      refute_includes composed, "POPULAR"
      refute_includes showcase, "--gradient-1"
    end
  end
end
