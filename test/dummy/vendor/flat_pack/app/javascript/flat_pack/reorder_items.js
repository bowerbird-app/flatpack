export function buildItems(ids) {
  return ids.map((id, index) => ({
    id,
    position: index + 1
  }))
}
