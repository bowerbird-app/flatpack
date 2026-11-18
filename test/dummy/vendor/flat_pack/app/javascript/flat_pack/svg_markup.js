const ALLOWED_SVG_TAGS = new Set([
  "svg",
  "path",
  "circle",
  "g",
  "rect",
  "line",
  "polyline",
  "polygon",
  "ellipse"
])

const ICON_SVG = /^<svg\b[^>]*>[\s\S]*<\/svg>$/i
const DISALLOWED = /<\s*\/?\s*(?!svg\b|path\b|circle\b|g\b|rect\b|line\b|polyline\b|polygon\b|ellipse\b)[a-z0-9:-]+|on[a-z]+\s*=|javascript:|<!--/i

export function allowlistedIconSvg(markup) {
  const source = String(markup || "").trim()
  if (!source) return ""
  if (typeof DOMParser === "undefined") {
    if (!ICON_SVG.test(source) || DISALLOWED.test(source)) return ""
    return source
  }

  const doc = new DOMParser().parseFromString(source, "image/svg+xml")
  const svg = doc.querySelector("svg")
  if (!svg || svg.querySelector("parsererror")) return ""

  prune(svg)
  return svg.outerHTML || ""
}

function prune(node) {
  stripHandlers(node)
  Array.from(node.children || []).forEach((child) => {
    const tag = String(child.tagName || "").toLowerCase()
    if (!ALLOWED_SVG_TAGS.has(tag)) {
      child.remove()
      return
    }
    prune(child)
  })
}

function stripHandlers(node) {
  Array.from(node.attributes || []).forEach((attr) => {
    const name = String(attr.name || "").toLowerCase()
    if (name.startsWith("on") || name === "href" || name === "xlink:href") {
      node.removeAttribute(attr.name)
    }
  })
}
