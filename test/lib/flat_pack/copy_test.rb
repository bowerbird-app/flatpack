# frozen_string_literal: true

require "test_helper"
require "yaml"

module FlatPack
  class CopyTest < ViewComponent::TestCase
    GEM_EN = FlatPack::Engine.root.join("config/locales/flatpack.en.yml")
    DUMMY_FR = FlatPack::Engine.root.join("test/dummy/config/locales/flatpack.fr.yml")

    test "kit chrome uses English defaults from the gem locale file" do
      render_inline(FlatPack::SkipLink::Component.new(href: "#main"))

      assert_text "Skip to content"
      assert_no_text "Aller au contenu"
    end

    test "dummy French locale overrides kit English defaults" do
      I18n.with_locale(:fr) do
        render_inline(FlatPack::SkipLink::Component.new(href: "#main"))
      end

      assert_text "Aller au contenu"
      assert_no_text "Skip to content"
    end

    test "explicit component props win over locale defaults" do
      I18n.with_locale(:fr) do
        render_inline(FlatPack::SkipLink::Component.new(href: "#main", text: "Jump ahead"))
      end

      assert_text "Jump ahead"
      assert_no_text "Aller au contenu"
      assert_no_text "Skip to content"
    end

    test "explicit nil still wins over locale defaults" do
      render_inline(FlatPack::Spinner::Component.new(label: nil))

      refute_includes page.native.to_html, 'aria-label="Loading"'
    end

    test "the gem ships only the English locale file under flatpack.*" do
      locale_files = Dir[FlatPack::Engine.root.join("config/locales/*")].map { |path| File.basename(path) }

      assert_equal ["flatpack.en.yml"], locale_files.sort
      refute_match(/^fr:/, File.read(GEM_EN))
    end

    test "dummy French locale covers every gem English key" do
      en_keys = leaf_keys(yaml_tree(GEM_EN, "en"))
      fr_keys = leaf_keys(yaml_tree(DUMMY_FR, "fr"))

      missing = en_keys - fr_keys
      extra = fr_keys - en_keys

      assert_empty missing, "dummy fr.yml is missing gem en keys: #{missing.sort.join(", ")}"
      assert_empty extra, "dummy fr.yml has keys the gem en file does not: #{extra.sort.join(", ")}"
    end

    test "JS_KEYS all exist in the gem English locale" do
      en_keys = leaf_keys(yaml_tree(GEM_EN, "en"))
      missing = FlatPack::Copy::JS_KEYS - en_keys

      assert_empty missing, "JS_KEYS missing from gem en.yml: #{missing.sort.join(", ")}"
    end

    test "js payload includes every JS_KEYS entry from the current locale" do
      payload = FlatPack::Copy.js_payload

      assert_equal FlatPack::Copy::JS_KEYS.sort, payload.keys.sort
      assert_equal "Show password", payload["password.show"]
      refute payload.values.any? { |value| value.to_s.start_with?("translation missing") }

      I18n.with_locale(:fr) do
        french = FlatPack::Copy.js_payload

        assert_equal "Afficher le mot de passe", french["password.show"]
        refute french.values.any? { |value| value.to_s.start_with?("translation missing") }
      end
    end

    test "French kit chrome uses dummy translations for billing alerts" do
      I18n.with_locale(:fr) do
        render_inline(FlatPack::Billing::StatusAlert::Component.new(status: :past_due))
      end

      assert_text "Impayé"
      assert_text "Mettez à jour votre moyen de paiement"
      assert_no_text "Past due"
    end

    private

    def yaml_tree(path, locale)
      YAML.safe_load_file(path).fetch(locale).fetch("flatpack")
    end

    def leaf_keys(tree, prefix = [])
      tree.flat_map do |key, value|
        path = prefix + [key.to_s]
        if value.is_a?(Hash)
          leaf_keys(value, path)
        else
          [path.join(".")]
        end
      end
    end
  end
end
