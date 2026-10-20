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

    test "copy.js English fallback includes every JS key" do
      source = File.read(FlatPack::Engine.root.join("app/javascript/flat_pack/copy.js"))
      missing = FlatPack::Copy::JS_KEYS.reject { |key| source.include?(%("#{key}")) }

      assert_empty missing, "copy.js ENGLISH is missing: #{missing.sort.join(", ")}"
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

    test "a locale missing flatpack keys uses the English strings" do
      without_i18n_fallbacks do
        with_available_locale(:ms) do
          I18n.with_locale(:ms) do
            refute I18n.exists?("flatpack.page_nav.label", :ms)
            refute I18n.exists?("flatpack.top_nav.more", :ms)
            refute I18n.exists?("flatpack.page_nav.previous", :ms)

            assert_equal "Host pages", FlatPack::Copy.t("page_nav.label")
            assert_equal "More navigation items", FlatPack::Copy.t("top_nav.more")
            assert_equal "Previous page", FlatPack::Copy.t("page_nav.previous")
            assert_equal "Page 4", FlatPack::Copy.t("pagination.page", number: 4)
            refute_match(/translation missing/i, FlatPack::Copy.t("page_nav.label"))
          end

          assert_equal "Host pages", FlatPack::Copy.t("page_nav.label", locale: :ms)
        end
      end
    end

    test "page nav in a locale without those keys renders English labels" do
      without_i18n_fallbacks do
        with_available_locale(:ms) do
          I18n.with_locale(:ms) do
            render_inline(FlatPack::PageNav::Component.new) { |nav| nav.with_back }
          end
        end
      end

      html = page.native.to_html
      assert_includes html, 'aria-label="Host pages"'
      assert_includes html, 'aria-label="Go back"'
      refute_includes html, "translation missing"
      refute_includes html, "translation_missing"
    end

    test "a host English file overrides the gem string and is the fallback" do
      path = Rails.root.join("config/locales/flatpack_overrides.en.yml")

      assert_includes I18n.load_path.map { |entry| Pathname(entry).cleanpath.to_s }, path.cleanpath.to_s
      assert_equal "Host pages", FlatPack::Copy.t("page_nav.label", locale: :en)

      events = []
      callback = ->(*args) { events << ActiveSupport::Notifications::Event.new(*args) }

      without_i18n_fallbacks do
        with_available_locale(:ms) do
          ActiveSupport::Notifications.subscribed(callback, "fallback.flat_pack_copy") do
            I18n.with_locale(:ms) do
              refute I18n.exists?("flatpack.page_nav.label", :ms)
              assert_equal "Host pages", FlatPack::Copy.t("page_nav.label")
            end

            assert_equal "Host pages", FlatPack::Copy.t("page_nav.label", locale: :en)
          end
        end
      end

      assert_equal [["flatpack.page_nav.label", :ms]], events.map { |event| [event.payload[:key], event.payload[:locale]] }
    end

    test "Copy.t rejects scope so the fallback stays under flatpack" do
      error = assert_raises(ArgumentError) { FlatPack::Copy.t("page_nav.label", scope: "host") }

      assert_match(/scope/, error.message)
    end

    test "a translation in the active locale wins over English" do
      without_i18n_fallbacks do
        with_available_locale(:ms) do
          I18n.backend.store_translations(:ms, flatpack: {page_nav: {label: "Navigasi halaman"}})

          I18n.with_locale(:ms) do
            assert_equal "Navigasi halaman", FlatPack::Copy.t("page_nav.label")
            assert_equal "Previous page", FlatPack::Copy.t("page_nav.previous")
          end
        end
      end
    ensure
      I18n.reload!
    end

    test "an explicit default stays with I18n when the locale is missing the key" do
      without_i18n_fallbacks do
        with_available_locale(:ms) do
          I18n.with_locale(:ms) do
            assert_equal "Custom", FlatPack::Copy.t("page_nav.label", default: "Custom")
          end
        end
      end
    end

    test "copy lookup does not install an I18n exception handler" do
      handler = I18n.exception_handler

      without_i18n_fallbacks do
        with_available_locale(:ms) do
          I18n.with_locale(:ms) do
            FlatPack::Copy.t("page_nav.label")
            message = I18n.t("flatpack.page_nav.label")

            assert_match(/translation missing/i, message.to_s)
          end
        end
      end

      assert_same handler, I18n.exception_handler
    end

    test "raise_on_missing_translations still raises for a missing non-flatpack key" do
      without_i18n_fallbacks do
        with_raise_on_missing_translations do
          with_available_locale(:ms) do
            I18n.with_locale(:ms) do
              error = assert_raises(I18n::MissingTranslationData) { I18n.t("host.missing.label") }
              assert_match(/host\.missing\.label/, error.message)

              assert_equal "Host pages", FlatPack::Copy.t("page_nav.label")
            end

            error = assert_raises(I18n::MissingTranslationData) { I18n.t("host.missing.label") }
            assert_match(/host\.missing\.label/, error.message)
          end
        end
      end
    end

    test "a flatpack key missing in English still raises when the host raises on missing translations" do
      without_i18n_fallbacks do
        with_raise_on_missing_translations do
          error = assert_raises(I18n::MissingTranslationData) do
            FlatPack::Copy.t("not_a_real_flatpack_key")
          end
          assert_match(/flatpack\.not_a_real_flatpack_key/, error.message)

          with_available_locale(:ms) do
            I18n.with_locale(:ms) do
              assert_raises(I18n::MissingTranslationData) do
                FlatPack::Copy.t("not_a_real_flatpack_key")
              end
            end
          end
        end
      end
    end

    test "a flatpack key missing in English keeps the missing-translation message when the host does not raise" do
      message = FlatPack::Copy.t("not_a_real_flatpack_key")

      assert_match(/translation missing/i, message.to_s)
      assert_match(/flatpack\.not_a_real_flatpack_key/, message.to_s)
    end

    private

    def with_available_locale(locale)
      previous_locales = I18n.available_locales
      previous_locale = I18n.locale

      I18n.available_locales = (previous_locales + [locale.to_sym, :en]).uniq
      yield
    ensure
      I18n.available_locales = previous_locales
      I18n.locale = previous_locale
    end

    def without_i18n_fallbacks
      previous = I18n.fallbacks
      I18n.fallbacks = I18n::Locale::Fallbacks.new
      yield
    ensure
      I18n.fallbacks = previous
    end

    def with_raise_on_missing_translations
      previous_handler = I18n.exception_handler
      previous_raise = Rails.application.config.i18n.raise_on_missing_translations
      previous_view_raise = ActionView::Helpers::TranslationHelper.raise_on_missing_translations

      Rails.application.config.i18n.raise_on_missing_translations = true
      ActionView::Helpers::TranslationHelper.raise_on_missing_translations = true
      I18n.exception_handler = ->(exception, *) {
        exception = exception.to_exception if exception.is_a?(I18n::MissingTranslation)
        raise exception
      }

      yield
    ensure
      I18n.exception_handler = previous_handler
      Rails.application.config.i18n.raise_on_missing_translations = previous_raise
      ActionView::Helpers::TranslationHelper.raise_on_missing_translations = previous_view_raise
    end

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
