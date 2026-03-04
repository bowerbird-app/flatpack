# frozen_string_literal: true

class ThemesController < ApplicationController
  THEME_TOKEN_GROUPS = {
    "Core Colors and Surfaces" => [/\A--(color-|surface-|gradient-)/],
    "Badges" => [/\A--badge-/],
    "Buttons" => [/\A--button-/],
    "Alerts" => [/\A--alert-/],
    "Toasts" => [/\A--toast-/],
    "Cards" => [/\A--card-/],
    "Accordion" => [/\A--accordion-/],
    "Collapse" => [/\A--collapse-/],
    "Breadcrumbs" => [/\A--breadcrumb-/],
    "Bottom Nav" => [/\A--bottom-nav-/],
    "Code Blocks" => [/\A--code-block-/],
    "Comments" => [/\A--comments-/],
    "Quote" => [/\A--quote-/],
    "Timeline" => [/\A--timeline-/],
    "Tabs" => [/\A--tabs-/],
    "Modals" => [/\A--modal-/],
    "Popovers" => [/\A--popover-/],
    "Tooltips" => [/\A--tooltip-/],
    "Switch" => [/\A--switch-/],
    "Skeleton" => [/\A--skeleton-/],
    "Sidebar" => [/\A--sidebar-/],
    "Top Nav" => [/\A--top-nav-/],
    "Search" => [/\A--search-/],
    "Chat" => [/\A--chat-/],
    "Table" => [/\A--table-/],
    "Chips" => [/\A--chip-/],
    "Form Controls" => [/\A--form-control-/],
    "Avatars" => [/\A--avatar-/],
    "Radii" => [/\A--radius-/],
    "Shadows" => [/\A--shadow-/],
    "Motion" => [/\A--duration-/],
    "Backdrop Effects" => [/\A--blur-/],
    "Other" => [/.*/]
  }.freeze

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
    @theme_token_groups = build_theme_token_groups
  end

  def demo
    @demo_theme = params[:theme]

    return head :not_found unless DEMO_THEMES.key?(@demo_theme)

    @demo_theme_label = DEMO_THEMES.fetch(@demo_theme)
    @theme_variables_code = theme_variables_code(@demo_theme)
  end

  private

  def theme_variables_code(theme)
    css = cached_theme_variables_css

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

  def build_theme_token_groups
    tokens = extract_theme_tokens

    grouped_tokens = tokens.group_by do |token|
      group_for_token(token.fetch(:variable))
    end

    THEME_TOKEN_GROUPS.each_with_object([]) do |(title, _patterns), groups|
      rows = grouped_tokens.fetch(title, [])
      next if rows.empty?

      groups << {
        title: title,
        subtitle: "#{rows.size} token#{"s" unless rows.size == 1} in @theme",
        rows: rows
      }
    end
  end

  def extract_theme_tokens
    css = cached_theme_variables_css
    block = css[/@theme\s*\{(?<body>.*?)^\}/m, :body]
    return [] if block.blank?

    block.lines.filter_map do |line|
      stripped = line.strip
      next if stripped.empty? || stripped.start_with?("/*")

      match = stripped.match(/\A(--[a-z0-9-]+)\s*:\s*(.+);\z/)
      next unless match

      {
        variable: match[1],
        default_value: match[2],
        description: default_value_description(match[2])
      }
    end
  end

  def cached_theme_variables_css
    path = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css")
    mtime = File.mtime(path).to_i

    cache = self.class.instance_variable_get(:@theme_variables_css_cache)
    if cache&.fetch(:mtime, nil) == mtime
      return cache.fetch(:css)
    end

    css = File.read(path)
    self.class.instance_variable_set(:@theme_variables_css_cache, {mtime: mtime, css: css})
    css
  end

  def group_for_token(variable)
    THEME_TOKEN_GROUPS.each do |title, patterns|
      return title if patterns.any? { |pattern| variable.match?(pattern) }
    end

    "Other"
  end

  def default_value_description(default_value)
    return "References another token via var()" if default_value.start_with?("var(")
    return "Gradient token value" if default_value.start_with?("linear-gradient(")
    return "Color value" if default_value.include?("oklch(") || default_value.include?("rgb(") || default_value.include?("color-mix(")

    "Theme token value"
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
    when /\A--accordion-/
      "Accordion"
    when /\A--collapse-/
      "Collapse"
    when /\A--breadcrumb-/
      "Breadcrumbs"
    when /\A--bottom-nav-/
      "Bottom nav"
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
    when /\A--comments-/
      "Comments"
    when /\A--quote-/
      "Quote"
    when /\A--timeline-/
      "Timeline"
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
    when /\A--search-/
      "Search"
    when /\A--form-control-/
      "Form controls"
    when /\A--table-/
      "Table"
    when /\A--tabs-/
      "Tabs"
    when /\A--switch-/
      "Switch"
    when /\A--skeleton-/
      "Skeleton"
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
