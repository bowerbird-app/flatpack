# frozen_string_literal: true

require "test_helper"

class ThemesControllerPrivateTest < ActiveSupport::TestCase
  test "extract_selector_block returns fallback when selector is missing" do
    controller = ThemesController.new

    block = controller.send(:extract_selector_block, ":root {\n  --color-primary: #111;\n}\n", "[data-theme=\"missing\"]")

    assert_includes block, "[data-theme=\"missing\"]"
    assert_includes block, "Variables for this selector were not found"
  end

  test "format_variables_with_sections groups raw and variable lines" do
    controller = ThemesController.new

    body = <<~CSS
      --color-primary: #111;
      --color-ring: #222;
      color: red;
    CSS

    formatted = controller.send(:format_variables_with_sections, body)

    assert_includes formatted, "/* Core colors and surfaces */"
    assert_includes formatted, "--color-primary: #111;"
    assert_includes formatted, "/* Focus */"
    assert_includes formatted, "--color-ring: #222;"
    assert_includes formatted, "/* Other */"
    assert_includes formatted, "color: red;"
  end

  test "theme_variables_code returns selector content for light theme" do
    controller = ThemesController.new

    code = controller.send(:theme_variables_code, "light")

    assert_includes code, ":root"
    assert_includes code, "--color-primary"
  end

  test "cached theme variables css exposes warning utility helpers" do
    controller = ThemesController.new

    css = controller.send(:cached_theme_variables_css)

    assert_includes css, ".text-warning"
    assert_includes css, "color: var(--color-warning-border);"
    assert_includes css, ".border-warning"
    assert_includes css, "border-color: var(--color-warning-border);"
  end

  test "variable_section_label classifies blur and unknown variables" do
    controller = ThemesController.new

    assert_equal "Backdrop effects", controller.send(:variable_section_label, "--blur-strong")
    assert_equal "Other", controller.send(:variable_section_label, "--custom-token")
  end
end
