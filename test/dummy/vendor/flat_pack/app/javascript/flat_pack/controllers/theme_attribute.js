const BUILT_IN_BASES = ["light", "dark", "ocean", "rounded"]

export function readThemeNames(attributeValue) {
  if (typeof attributeValue !== "string") return []

  return attributeValue.trim().split(/\s+/).filter(Boolean)
}

export function themeListIncludes(attributeValue, name) {
  return readThemeNames(attributeValue).includes(name)
}

export function composeThemeAttribute(currentValue, nextBase, extraOwned = []) {
  const owned = new Set(BUILT_IN_BASES)

  extraOwned.forEach((name) => {
    if (typeof name === "string" && name.length > 0 && name !== "system") owned.add(name)
  })

  const kept = readThemeNames(currentValue).filter((name) => name !== nextBase && !owned.has(name))

  if (nextBase == null || nextBase === "" || nextBase === "light") {
    return kept.length ? kept.join(" ") : null
  }

  return [nextBase, ...kept].join(" ")
}

export function readPickerThemeNames(doc = globalThis.document) {
  if (!doc?.querySelector) return []

  const raw = doc.querySelector("[data-flat-pack--theme-themes-value]")?.getAttribute("data-flat-pack--theme-themes-value")
  if (!raw) return []

  try {
    const parsed = JSON.parse(raw)
    if (!Array.isArray(parsed)) return []

    return parsed.map((item) => {
      if (typeof item === "string") return item
      if (item && typeof item.value === "string") return item.value
      return null
    }).filter((name) => typeof name === "string" && name.length > 0)
  } catch {
    return []
  }
}
