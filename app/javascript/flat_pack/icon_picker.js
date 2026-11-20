export function normalizeIconQuery(text) {
  return String(text ?? "").toLowerCase().replace(/[-\s]+/g, "")
}

export function iconMatches(name, query) {
  const needle = normalizeIconQuery(query)
  if (!needle) return true

  return normalizeIconQuery(name).includes(needle)
}

const MOVE_KEYS = new Set(["ArrowRight", "ArrowLeft", "ArrowDown", "ArrowUp", "Home", "End"])

export function isGridMoveKey(key) {
  return MOVE_KEYS.has(key)
}

export function moveIndex(index, count, columns, key) {
  if (count <= 0) return 0

  const cols = Math.max(Number(columns) || 1, 1)
  let next = index

  if (key === "ArrowRight") next = index + 1
  else if (key === "ArrowLeft") next = index - 1
  else if (key === "ArrowDown") next = index + cols
  else if (key === "ArrowUp") next = index - cols
  else if (key === "Home") next = 0
  else if (key === "End") next = count - 1
  else return index

  if (next < 0 || next >= count) return index

  return next
}
