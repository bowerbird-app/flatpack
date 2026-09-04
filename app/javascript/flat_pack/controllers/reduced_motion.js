const QUERY = "(prefers-reduced-motion: reduce)"
const DURATION_MS = {
  fast: 150,
  base: 200,
  slow: 300
}

export function prefersReducedMotion() {
  return Boolean(globalThis.matchMedia?.(QUERY).matches)
}

export function motionDuration(token = "slow") {
  if (prefersReducedMotion()) return 0

  return readDurationToken(token)
}

function readDurationToken(token) {
  const fallback = DURATION_MS[token] ?? DURATION_MS.slow

  if (typeof document === "undefined" || !document.documentElement) {
    return fallback
  }

  const raw = getComputedStyle(document.documentElement).getPropertyValue(`--duration-${token}`).trim()
  if (!raw) return fallback

  const value = Number.parseFloat(raw)
  if (Number.isNaN(value)) return fallback
  if (raw.endsWith("ms")) return value
  if (raw.endsWith("s")) return value * 1000

  return value
}
