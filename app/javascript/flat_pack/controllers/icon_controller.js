import { Controller } from "@hotwired/stimulus"
import { outline, solid } from "flat_pack/heroicons"

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

const ICON_BANKS = { outline, solid, mini: solid, micro: solid }

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

    // Remove attributes that don't apply to this variant
    if (variant === "solid" || variant === "mini" || variant === "micro") {
      this.element.removeAttribute("stroke")
      this.element.removeAttribute("stroke-width")
    } else {
      this.element.removeAttribute("fill-rule")
    }

    this.element.innerHTML = paths
  }
}
