// Shared debounce and aborting GET for remote search.
// Select, Picker, Search, and Combobox keep their own JSON shape and UI.
// A new fetch aborts the previous one. stop() clears the timer and aborts.

export function createRemoteQuery() {
  let debounceTimer = null
  let abortController = null

  function clearDebounce() {
    if (!debounceTimer) return
    clearTimeout(debounceTimer)
    debounceTimer = null
  }

  function abort() {
    if (!abortController) return
    abortController.abort()
    abortController = null
  }

  return {
    clearDebounce,
    abort,
    stop() {
      clearDebounce()
      abort()
    },
    debounce(wait, run) {
      clearDebounce()
      debounceTimer = setTimeout(() => {
        debounceTimer = null
        run()
      }, wait)
    },
    fetch(endpoint, { query = "", param = "q", params = {} } = {}) {
      abort()
      abortController = new AbortController()
      const url = new URL(endpoint, window.location.origin)
      url.searchParams.set(param, query)
      Object.entries(params).forEach(([key, value]) => {
        url.searchParams.set(key, value)
      })

      return fetch(url.toString(), {
        method: "GET",
        headers: { Accept: "application/json" },
        signal: abortController.signal
      })
    }
  }
}
