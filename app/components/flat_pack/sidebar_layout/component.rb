# frozen_string_literal: true

module FlatPack
  module SidebarLayout
    class Component < FlatPack::BaseComponent
      renders_one :sidebar_slot
      renders_one :top_nav_slot
      renders_one :main_slot
      renders_one :background_slot

      CONTENT_SCROLLS = %i[behind below].freeze
      HEIGHTS = %i[full content].freeze
      WIDTHS = %i[fixed content].freeze

      def initialize(
        side: :left,
        open: true,
        storage_key: nil,
        floating: false,
        floating_top_nav: false,
        content_scroll: :behind,
        height: :full,
        width: :fixed,
        resizable: false,
        **system_arguments
      )
        super(**system_arguments)
        @side = side.to_sym
        @open = open
        @storage_key = storage_key
        @floating = floating
        @floating_top_nav = floating_top_nav
        @content_scroll = content_scroll.is_a?(String) ? content_scroll.to_sym : content_scroll
        @height = height.is_a?(String) ? height.to_sym : height
        @width = width.is_a?(String) ? width.to_sym : width
        @resizable = resizable

        validate_side!
        validate_floating!
        validate_floating_top_nav!
        validate_content_scroll!
        validate_height!
        validate_width!
        validate_resizable!(@resizable)
      end

      def sidebar(**args, &block)
        return sidebar_slot unless block

        with_sidebar_slot(**args, &block)
      end

      def top_nav(**args, &block)
        return top_nav_slot unless block

        with_top_nav_slot(**args, &block)
      end

      def main(**args, &block)
        return main_slot unless block

        with_main_slot(**args, &block)
      end

      def background(**args, &block)
        return background_slot unless block

        with_background_slot(**args, &block)
      end

      def sidebar?
        sidebar_slot?
      end

      def top_nav?
        top_nav_slot?
      end

      def main?
        main_slot?
      end

      def background?
        background_slot?
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_background,
            render_sidebar_and_main,
            render_backdrop
          ].compact)
        end
      end

      private

      def render_sidebar_and_main
        if @side == :right
          safe_join([
            render_main_column,
            render_sidebar_column
          ].compact)
        else
          safe_join([
            render_sidebar_column,
            render_main_column
          ].compact)
        end
      end

      def render_sidebar_column
        render_panel(rail_panel, sidebar.to_s) if sidebar?
      end

      def render_panel(panel, body)
        # The collapse script stays the first child so it runs before the
        # rail <aside> is parsed. CSS then sizes the column before first paint.
        content_tag(
          :div,
          safe_join([preamble(panel), body, resize_handle(panel)].compact),
          **panel_tag_attributes(panel)
        )
      end

      def panel_tag_attributes(panel)
        {
          class: classes(*panel.column_classes),
          data: panel.column_data
        }
      end

      def preamble(panel)
        fouc_prevention_script if panel.role == :rail
      end

      def resize_handle(panel)
        return unless panel.resizable

        content_tag(
          :div,
          "",
          class: "fp-panel-resize hidden md:block",
          role: "separator",
          tabindex: "0",
          aria: {orientation: "vertical", label: panel.resize_label},
          data: {
            "flat-pack--panel-resize-target": "handle",
            action: "pointerdown->flat-pack--panel-resize#start keydown->flat-pack--panel-resize#nudge dblclick->flat-pack--panel-resize#reset"
          }
        )
      end

      def rail_panel
        Panel.rail(
          edge: @side,
          open: @open,
          resizable: @resizable,
          width_mode: @width,
          floating: @floating,
          content_height: content_height?,
          storage_key: @storage_key
        )
      end

      def fouc_prevention_script
        return unless @storage_key

        # Runs synchronously during HTML parsing (before <aside> is encountered).
        # Sets data-flat-pack-sidebar-collapsed on the wrapper div so CSS can
        # size the sidebar correctly before the first paint — no JS-driven
        # layout shift needed.
        js = <<~JS.strip
          (function(){
            try{
              var k=#{@storage_key.to_json},d=#{@open ? "true" : "false"};
              var s=localStorage.getItem(k);
              var c=s!==null?s==='true':!d;
              document.currentScript.parentElement
                .setAttribute('data-flat-pack-sidebar-collapsed',c?'true':'false');
            }catch(e){}
          })();
        JS
        content_tag(:script, js.html_safe)
      end

      def render_main_column
        content_tag(:div, class: main_column_classes) do
          safe_join([
            render_top_nav,
            content_tag(:div, class: main_content_classes) do
              main? ? main.to_s : content
            end
          ].compact)
        end
      end

      def render_top_nav
        return unless top_nav?
        return top_nav unless @floating_top_nav

        content_tag(:div, top_nav.to_s, **top_nav_float_attributes)
      end

      def top_nav_float_attributes
        {
          class: "fp-layout-top-nav",
          data: {"flat-pack-top-nav-floating": @content_scroll.to_s}
        }
      end

      def render_background
        return unless background?

        content_tag(
          :div,
          safe_join([
            content_tag(:div, background.to_s, class: "fp-layout-background-media"),
            content_tag(:div, "", class: "fp-layout-background-tint")
          ]),
          class: "fp-layout-background",
          aria: {hidden: true}
        )
      end

      def render_backdrop
        content_tag(:div, "", **backdrop_attributes)
      end

      def container_attributes
        merge_attributes(
          class: container_classes,
          data: controller_data
        )
      end

      def controller_data
        {
          controller: "flat-pack--sidebar-layout",
          "flat-pack--sidebar-layout-side-value": @side.to_s,
          "flat-pack--sidebar-layout-open-value": @open,
          "flat-pack--sidebar-layout-storage-key-value": @storage_key,
          "flat-pack-layout-background": ("true" if background?)
        }.compact
      end

      def container_classes
        classes(
          "grid",
          "h-screen",
          "overflow-hidden",
          grid_columns_classes
        )
      end

      def grid_columns_classes
        if @side == :right
          "grid-cols-[1fr_auto]"
        else
          "grid-cols-[auto_1fr]"
        end
      end

      def main_column_classes
        classes(
          "flex",
          "flex-col",
          "min-w-0",
          "min-h-0",
          "overflow-hidden",
          ("relative" if floating_top_nav_active?),
          ("fp-layout-main" if background?)
        )
      end

      def main_content_classes
        classes(
          "flex-1 min-h-0 overflow-y-auto overscroll-y-contain",
          ("fp-layout-scroll" if floating_top_nav_active? && @content_scroll == :behind)
        )
      end

      def floating_top_nav_active?
        @floating_top_nav && top_nav?
      end

      def content_height?
        @floating && @height == :content
      end

      def backdrop_attributes
        {
          class: backdrop_classes,
          data: {
            "flat-pack--sidebar-layout-target": "backdrop",
            action: "click->flat-pack--sidebar-layout#closeMobile"
          },
          aria: {
            hidden: true
          }
        }
      end

      def backdrop_classes
        "fixed inset-0 bg-[var(--drawer-backdrop-color)] z-40 md:hidden opacity-0 pointer-events-none transition-opacity duration-[var(--duration-slow)] ease-[var(--easing-enter)]"
      end

      def validate_side!
        return if [:left, :right].include?(@side)
        raise ArgumentError, "Invalid side: #{@side}. Must be :left or :right"
      end

      def validate_floating!
        return if @floating == true || @floating == false

        raise ArgumentError, "floating must be true or false"
      end

      def validate_floating_top_nav!
        return if @floating_top_nav == true || @floating_top_nav == false

        raise ArgumentError, "floating_top_nav must be true or false"
      end

      def validate_content_scroll!
        return if CONTENT_SCROLLS.include?(@content_scroll)

        raise ArgumentError, "content_scroll must be :behind or :below"
      end

      def validate_height!
        return if HEIGHTS.include?(@height)

        raise ArgumentError, "height must be :full or :content"
      end

      def validate_width!
        return if WIDTHS.include?(@width)

        raise ArgumentError, "width must be :fixed or :content"
      end

      def validate_resizable!(value)
        return if value == true || value == false

        raise ArgumentError, "resizable must be true or false"
      end
    end
  end
end
