export function initLocalTimes(root = document, now = new Date()) {
  root.querySelectorAll("time.local-time").forEach((element) => {
    updateLocalTimeElement(element, now)
  })
}

export function updateLocalTimeElement(element, now = new Date()) {
  const datetime = element.getAttribute("datetime")

  if (!datetime) return

  const date = new Date(datetime)

  if (Number.isNaN(date.getTime())) return

  if (!element.hasAttribute("title")) {
    element.setAttribute("title", datetime)
  }

  if (element.classList.contains("relative-time")) {
    element.textContent = formatRelativeTime(date, now)
  } else {
    element.textContent = formatLocalTime(date)
  }
}

export function formatLocalTime(date) {
  return date.toLocaleString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit"
  })
}

export function formatRelativeTime(date, now = new Date()) {
  const elapsedSeconds = Math.floor((now - date) / 1000)

  if (elapsedSeconds < 60) return "Just now"

  const elapsedMinutes = Math.floor(elapsedSeconds / 60)
  if (elapsedMinutes < 60) return `${elapsedMinutes} minutes ago`

  const elapsedHours = Math.floor(elapsedMinutes / 60)
  if (elapsedHours < 24) return `${elapsedHours} hours ago`

  const elapsedDays = Math.floor(elapsedHours / 24)
  if (elapsedDays < 2) return "Yesterday"
  if (elapsedDays < 7) return `${elapsedDays} days ago`

  const elapsedWeeks = Math.floor(elapsedDays / 7)
  if (elapsedDays < 30) return `${elapsedWeeks} weeks ago`

  const elapsedMonths = Math.floor(elapsedDays / 30)
  if (elapsedDays < 365) return `${elapsedMonths} months ago`

  return formatAbsoluteDate(date)
}

export function formatAbsoluteDate(date) {
  return date.toLocaleDateString(undefined, {
    year: "numeric",
    month: "long",
    day: "numeric"
  })
}

