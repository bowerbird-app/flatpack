# frozen_string_literal: true

class ThemesController < ApplicationController
  DEMO_THEMES = {
    "system" => "System",
    "light" => "Light",
    "dark" => "Dark",
    "ocean" => "Ocean",
    "rounded" => "Rounded"
  }.freeze

  THEME_SELECTORS = {
    "light" => ":root",
    "dark" => "[data-theme=\"dark\"]",
    "ocean" => "[data-theme=\"ocean\"]",
    "rounded" => "[data-theme=\"rounded\"]"
  }.freeze

  def index
    # Theme showcase page
  end

  def demo
    @demo_theme = params[:theme]

    return head :not_found unless DEMO_THEMES.key?(@demo_theme)

    @demo_theme_label = DEMO_THEMES.fetch(@demo_theme)
    @theme_variables_code = theme_variables_code(@demo_theme)
  end

  private

  def theme_variables_code(theme)
    css = File.read(FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css"))

    if theme == "system"
      light_block = extract_selector_block(css, THEME_SELECTORS.fetch("light"))
      dark_block = extract_selector_block(css, THEME_SELECTORS.fetch("dark"))

      return <<~CODE
        /*
         * System theme tracks the OS preference.
         * Base values come from :root and dark-mode values apply when the OS prefers dark.
         */

        #{light_block}

        /* Applied when the system preference is dark */
        #{dark_block}
      CODE
    end

    selector = THEME_SELECTORS.fetch(theme)
    extract_selector_block(css, selector)
  end

  def extract_selector_block(css, selector)
    pattern = /^#{Regexp.escape(selector)}\s*\{\n(?<body>.*?)^\}/m
    match = css.match(pattern)

    return "#{selector} {\n  /* Variables for this selector were not found. */\n}" unless match

    "#{selector} {\n#{format_variables_with_sections(match[:body])}}"
  end

  def format_variables_with_sections(body)
    section_order = []
    section_variables = Hash.new { |hash, key| hash[key] = [] }
    section_raw_lines = Hash.new { |hash, key| hash[key] = [] }

    body.lines.each do |line|
      stripped = line.strip
      next if stripped.empty?

      variable_name = stripped[/\A(--[a-z0-9-]+)\s*:/, 1]

      section = variable_name ? variable_section_label(variable_name) : "Other"
      section_order << section unless section_order.include?(section)

      if variable_name
        section_variables[section] << "  #{stripped}"
      else
        section_raw_lines[section] << line.rstrip
      end
    end

    formatted_lines = []
    section_order.each do |section|
      lines_for_section = section_variables[section] + section_raw_lines[section]
      next if lines_for_section.empty?

      formatted_lines << "" unless formatted_lines.empty?
      formatted_lines << "  /* #{section} */"
      formatted_lines.concat(lines_for_section)
    end

    "#{formatted_lines.join("\n")}\n"
  end

  def variable_section_label(variable_name)
    case variable_name
    when /\A--color-ring\z/
      "Focus"
    when /\A--(color-|gradient-|surface-)/
      "Core colors and surfaces"
    when /\A--code-block-/
      "Code block"
    when /\A--card-/
      "Cards"
    when /\A--modal-/
      "Modal"
    when /\A--popover-/
      "Popover"
    when /\A--tooltip-/
      "Tooltip"
    when /\A--sidebar-/
      "Sidebar"
    when /\A--badge-/
      "Badges"
    when /\A--chat-/
      "Chat"
    when /\A--button-/
      "Buttons"
    when /\A--alert-/
      "Alerts"
    when /\A--toast-/
      "Toasts"
    when /\A--avatar-/
      "Avatars"
    when /\A--top-nav-/
      "Top nav"
    when /\A--form-control-/
      "Form controls"
    when /\A--table-/
      "Table"
    when /\A--tabs-/
      "Tabs"
    when /\A--chip-/
      "Chips"
    when /\A--radius-/
      "Radii"
    when /\A--shadow-/
      "Shadows"
    when /\A--blur-/
      "Backdrop effects"
    else
      "Other"
    end
  end
end
