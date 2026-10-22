# frozen_string_literal: true

module FlatPack
  module SidebarLayout
    class Component < FlatPack::BaseComponent
      include FlatPack::Layout::Shell

      private :layout_top_nav, :layout_background, :layout_page_nav, :page_nav_classes

      renders_one :sidebar_slot
      renders_one :top_nav_slot
      renders_one :main_slot
      renders_one :background_slot
      renders_one :aside_slot

      CONTENT_SCROLLS = %i[behind below].freeze
      SCROLLS = %i[pane page].freeze
      HEIGHTS = %i[full content].freeze
      WIDTHS = %i[fixed content].freeze
      ASIDE_MOBILES = %i[drawer stack].freeze

      def initialize(
        side: :left,
        open: true,
        storage_key: nil,
        floating: false,
        floating_top_nav: false,
        content_scroll: :behind,
        scroll: :pane,
        scrollbar: :hidden,
        height: :full,
        width: :fixed,
        resizable: false,
        mobile_actions: :menu,
        **system_arguments
      )
        super(**system_arguments)
        @side = side.to_sym
        @open = open
        @storage_key = storage_key
        @floating = floating
        @floating_top_nav = floating_top_nav
        @content_scroll = content_scroll.is_a?(String) ? content_scroll.to_sym : content_scroll
        @scroll = scroll.is_a?(String) ? scroll.to_sym : scroll
        @scrollbar = FlatPack::PaneScroll.normalize!(scrollbar)
        @height = height.is_a?(String) ? height.to_sym : height
        @width = width.is_a?(String) ? width.to_sym : width
        @resizable = resizable
        assign_mobile_actions!(mobile_actions)
        @aside_open = true
        @aside_resizable = false
        @aside_mobile = :drawer
        @rail_id = "flat-pack-sidebar"
        @aside_id = "flat-pack-aside"

        validate_side!
        validate_floating!
        validate_floating_top_nav!
        validate_content_scroll!
        validate_scroll!
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

      def aside(open: true, resizable: false, mobile: :drawer, **args, &block)
        return aside_slot unless block

        validate_boolean!(open, "open")
        validate_resizable!(resizable)
        @aside_open = open
        @aside_resizable = resizable
        @aside_mobile = normalize_aside_mobile(mobile)
        with_aside_slot(**args, &block)
      end

      # A button the host places (usually in the top nav). The label is the
      # accessible name. The control targets the aside and carries
      # aria-expanded and aria-controls, so the host does not wire those.
      def aside_trigger(label = nil)
        name = label.to_s
        raise ArgumentError, "Aside trigger needs a label." if name.blank?

        render FlatPack::Button::Component.new(
          text: name,
          style: :ghost,
          size: :sm,
          aria: {expanded: (@aside_open ? "true" : "false"), controls: @aside_id},
          data: {
            "flat-pack--sidebar-layout-target": "asideToggle",
            action: "click->flat-pack--sidebar-layout#toggleAside"
          }
        )
      end

      def aside?
        aside_slot?
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_background,
            render_page_surface,
            render_columns,
            render_backdrop,
            render_floating_page_nav
          ].compact)
        end
      end

      private

      def render_columns
        return render_sidebar_and_main unless aside?

        parts = if @side == :right
          [render_aside_column, render_main_column, render_rail_column]
        else
          [render_rail_column, render_main_column, render_aside_column]
        end
        safe_join(parts.compact)
      end

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

      def render_rail_column
        render_sidebar_column
      end

      def render_sidebar_column
        render_panel(rail_panel, sidebar.to_s) if sidebar?
      end

      def render_aside_column
        render_panel(aside_panel, aside_landmark(aside_slot.to_s)) if aside?
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

      def aside_landmark(body)
        content_tag(:aside, body, **aside_scroll_attributes)
      end

      def aside_scroll_attributes
        FlatPack::PaneScroll.attributes(
          "fp-aside h-full min-h-0 overflow-y-auto overscroll-y-contain",
          label: fp_t("pane_scroll.aside"),
          scrollbar: @scrollbar
        )
      end

      def panel_tag_attributes(panel)
        attributes = {
          id: ((panel.role == :aside) ? @aside_id : @rail_id),
          class: classes(*panel.column_classes),
          data: panel.column_data
        }
        attributes[:style] = panel.column_style if panel.column_style
        attributes[:inert] = true if panel.role == :aside && panel.open == false && panel.mobile != :stack
        attributes
      end

      def preamble(panel)
        parts = if panel.role == :rail
          [fouc_prevention_script, panel_width_script(panel)]
        else
          [aside_state_script(panel)]
        end
        parts.compact!
        return if parts.empty?

        safe_join(parts)
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

      def aside_panel
        Panel.aside(
          edge: ((@side == :right) ? :left : :right),
          open: @aside_open,
          resizable: @aside_resizable,
          floating: @floating,
          content_height: content_height?,
          storage_key: @storage_key,
          mobile: @aside_mobile
        )
      end

      def aside_state_script(panel)
        open_key = panel.open_storage_key
        return if open_key.blank?

        js = <<~JS.strip
          (function(){
            try{
              var column=document.currentScript.parentElement;
              var stored=localStorage.getItem(#{open_key.to_json});
              var open=stored===null?#{panel.open ? "true" : "false"}:stored==="true";
              column.setAttribute("data-flat-pack-aside-open",open?"true":"false");
              #{aside_inert_js(panel)}
              #{width_apply_js(panel.resizable ? panel.width_storage_key : nil)}
            }catch(e){}
          })();
        JS
        content_tag(:script, js.html_safe)
      end

      def panel_width_script(panel)
        return unless panel.resizable

        key = panel.width_storage_key
        return if key.blank?

        js = <<~JS.strip
          (function(){
            try{
              var column=document.currentScript.parentElement;
              #{width_apply_js(key)}
            }catch(e){}
          })();
        JS
        content_tag(:script, js.html_safe)
      end

      def aside_inert_js(panel)
        if panel.mobile == :stack
          'if(open||!window.matchMedia("(min-width: 768px)").matches){column.removeAttribute("inert");}else{column.setAttribute("inert","");}'
        else
          'if(open){column.removeAttribute("inert");}else{column.setAttribute("inert","");}'
        end
      end

      def width_apply_js(key)
        return "" if key.blank?

        <<~JS.strip
          var panelLengthPx=function(raw){
            var value=String(raw||"").trim();
            var px=/^(-?[\\d.]+)px$/.exec(value);
            if(px){return parseFloat(px[1]);}
            var rem=/^(-?[\\d.]+)rem$/.exec(value);
            if(!rem){return NaN;}
            return parseFloat(rem[1])*parseFloat(getComputedStyle(document.documentElement).fontSize);
          };
          var width=localStorage.getItem(#{key.to_json});
          if(/^\\d+$/.test(width)){
            var raw=parseInt(width,10);
            var min=panelLengthPx(getComputedStyle(column).getPropertyValue("--fp-panel-min"));
            var max=panelLengthPx(getComputedStyle(column).getPropertyValue("--fp-panel-max"));
            if(Number.isFinite(min)&&Number.isFinite(max)){
              var next=Math.round(Math.min(max,Math.max(min,raw)));
              column.style.setProperty("--fp-panel-width",next+"px");
              column.setAttribute("data-flat-pack-panel-resized","true");
            }
          }
        JS
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
        # The view may register while the main slot renders. Read the registry after that.
        body = main? ? main.to_s : content
        content_tag(:div, class: main_column_classes, data: {"flat-pack-layout-main": "true"}) do
          safe_join([
            render_top_nav,
            layout_page_nav(styles: FlatPack::PageNavRoleStyles::QUIET, bar: true),
            content_tag(:div, body, **main_pane_attributes)
          ].compact)
        end
      end

      def render_top_nav
        return unless top_nav?

        layout_top_nav(top_nav.to_s, floating: @floating_top_nav, content_scroll: @content_scroll)
      end

      def render_page_surface
        return unless page_scroll? && @content_scroll == :behind && floating_top_nav_active? && !background?

        content_tag(:div, "", class: "fp-layout-page-surface", aria: {hidden: true})
      end

      def render_background
        return unless background?

        layout_background(background)
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
        data = {
          controller: "flat-pack--sidebar-layout",
          "flat-pack--sidebar-layout-side-value": @side.to_s,
          "flat-pack--sidebar-layout-open-value": @open,
          "flat-pack--sidebar-layout-storage-key-value": @storage_key,
          "flat-pack-layout-background": ("true" if background?),
          "flat-pack-layout-scroll": ("page" if page_scroll?)
        }
        if aside?
          data["flat-pack-layout-columns"] = layout_columns
          data["flat-pack-aside-mobile"] = @aside_mobile.to_s
          data["flat-pack--sidebar-layout-aside-open-value"] = @aside_open
          data["flat-pack--sidebar-layout-aside-mobile-value"] = @aside_mobile.to_s
          aside_key = aside_panel.open_storage_key
          data["flat-pack--sidebar-layout-aside-storage-key-value"] = aside_key if aside_key
        end
        data.compact
      end

      def container_classes
        classes(
          "grid",
          ("h-screen" unless page_scroll?),
          ("overflow-hidden" unless page_scroll?),
          grid_columns_classes
        )
      end

      def grid_columns_classes
        return ((@side == :right) ? "grid-cols-[1fr_auto]" : "grid-cols-[auto_1fr]") unless aside?

        nil
      end

      # Tracks live in kit CSS. A Tailwind `1fr` column is minmax(auto, 1fr),
      # so a wide main pane would push the aside out of the overflow-hidden shell.
      def layout_columns
        return "three" if sidebar?

        (@side == :left) ? "main-aside" : "aside-main"
      end

      def main_column_classes
        classes(
          "flex",
          "flex-col",
          "min-w-0",
          "min-h-0",
          ("overflow-hidden" unless page_scroll?),
          ("relative" if floating_top_nav_active?),
          ("fp-layout-main" if background?),
          ("fp-layout-page" if page_scroll? && floating_top_nav_active? && @content_scroll == :behind)
        )
      end

      def main_content_classes
        classes(
          page_scroll? ? "flex-1 min-h-0" : "flex-1 min-h-0 overflow-y-auto overscroll-y-contain",
          ("fp-layout-scroll" if floating_top_nav_active? && @content_scroll == :behind)
        )
      end

      def main_pane_attributes
        return {class: main_content_classes} if page_scroll?

        FlatPack::PaneScroll.attributes(
          main_content_classes,
          label: fp_t("pane_scroll.main"),
          scrollbar: @scrollbar
        )
      end

      def page_scroll?
        @scroll == :page
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

      def validate_scroll!
        unless SCROLLS.include?(@scroll)
          raise ArgumentError, "scroll must be :pane or :page"
        end

        return unless page_scroll? && @content_scroll == :below

        raise ArgumentError, "scroll: :page cannot be combined with content_scroll: :below"
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

      def validate_boolean!(value, name)
        return if value == true || value == false

        raise ArgumentError, "#{name} must be true or false"
      end

      def normalize_aside_mobile(mobile)
        value = mobile.is_a?(String) ? mobile.to_sym : mobile
        return value if ASIDE_MOBILES.include?(value)

        raise ArgumentError, "mobile must be :drawer or :stack"
      end
    end
  end
end
