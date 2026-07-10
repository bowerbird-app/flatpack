import { Controller } from "@hotwired/stimulus"
import { micro, mini, outline, solid } from "flat_pack/heroicons"

const VARIANT_ATTRS = {
  outline: {
    fill: "none",
    stroke: "currentColor",
    "stroke-width": "1.5",
  },
  solid: {
    fill: "currentColor",
  },
  mini: {
    fill: "currentColor",
  },
  micro: {
    fill: "currentColor",
  },
}

const ICON_BANKS = { outline, solid, mini, micro }

const VIEWBOXES = {
  outline: "0 0 24 24",
  solid: "0 0 24 24",
  mini: "0 0 20 20",
  micro: "0 0 16 16",
}

const RED_DOT_CONFIG = {
  outline: { cx: "20", cy: "4", r: "3" },
  solid: { cx: "20", cy: "4", r: "3" },
  mini: { cx: "16.5", cy: "3.5", r: "2.5" },
  micro: { cx: "13", cy: "3", r: "2" },
}

export default class extends Controller {
  static values = {
    name: String,
    variant: { type: String, default: "outline" },
  }

  connect() {
    this.#render()
  }

  nameValueChanged() {
    this.#render()
  }

  variantValueChanged() {
    this.#render()
  }

  #render() {
    const name = this.nameValue
    const variant = this.variantValue
    const bank = ICON_BANKS[variant] || outline
    const paths = bank[name] || outline[name]

    if (!paths) {
      if (typeof console !== "undefined") {
        console.warn(`[FlatPack] Unknown heroicon: "${name}"`)
      }
      return
    }

    // Set SVG presentation attributes for the chosen variant
    const attrs = VARIANT_ATTRS[variant] || VARIANT_ATTRS.outline
    Object.entries(attrs).forEach(([k, v]) => this.element.setAttribute(k, v))
    this.element.setAttribute("viewBox", VIEWBOXES[variant] || VIEWBOXES.outline)

    // Remove attributes that don't apply to this variant
    if (variant === "solid" || variant === "mini" || variant === "micro") {
      this.element.removeAttribute("stroke")
      this.element.removeAttribute("stroke-width")
    } else {
      this.element.removeAttribute("fill-rule")
    }

    this.element.innerHTML = paths

    if (this.element.classList.contains("fp-red-dot")) {
      this.#appendRedDot(variant)
    }
  }

  #appendRedDot(variant) {
    const config = RED_DOT_CONFIG[variant] || RED_DOT_CONFIG.outline
    const dot = document.createElementNS("http://www.w3.org/2000/svg", "circle")

    dot.setAttribute("class", "fp-red-dot-indicator")
    dot.setAttribute("cx", config.cx)
    dot.setAttribute("cy", config.cy)
    dot.setAttribute("r", config.r)

    this.element.appendChild(dot)
  }
}
