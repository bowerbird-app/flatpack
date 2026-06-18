import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "trigger",
    "panel",
    "listView",
    "calendarView",
    "monthLabel",
    "calendarGrid",
    "summary",
    "singleField",
    "rangeStartField",
    "rangeEndField"
  ]

  static values = {
    range: { type: Boolean, default: false },
    min: String,
    max: String,
    value: String,
    start: String,
    end: String,
    presetKey: String,
    presetLabels: Object,
    panelId: String
  }

  connect() {
    this.spacing = 8
    this.viewportPadding = 8

    this.today = this.startOfDay(new Date())
    this.visibleMonth = this.initialVisibleMonth()
    this.committed = this.initialCommittedValues()
    this.draft = { ...this.committed }
    this.viewMode = this.defaultViewMode()
    this.committedPresetKey = this.initialPresetKey()
    this.draftPresetKey = this.committedPresetKey

    this.isOpen = false
    this.panelElement = this.hasPanelTarget ? this.panelTarget : document.getElementById(this.panelIdValue)
    this.monthLabelElement = this.hasMonthLabelTarget ? this.monthLabelTarget : this.panelElement?.querySelector('[data-flat-pack--flatpack-date-picker-target="monthLabel"]')
    this.calendarGridElement = this.hasCalendarGridTarget ? this.calendarGridTarget : this.panelElement?.querySelector('[data-flat-pack--flatpack-date-picker-target="calendarGrid"]')
    this.summaryElement = this.hasSummaryTarget ? this.summaryTarget : this.panelElement?.querySelector('[data-flat-pack--flatpack-date-picker-target="summary"]')
    this.listViewElement = this.hasListViewTarget ? this.listViewTarget : this.panelElement?.querySelector('[data-flat-pack--flatpack-date-picker-target="listView"]')
    this.calendarViewElement = this.hasCalendarViewTarget ? this.calendarViewTarget : this.panelElement?.querySelector('[data-flat-pack--flatpack-date-picker-target="calendarView"]')
    this.panelOriginalParent = null
    this.panelOriginalNextSibling = null

    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    this.handlePanelClick = this.handlePanelClick.bind(this)
    this.handleEscape = this.handleEscape.bind(this)
    this.handleReposition = this.handleReposition.bind(this)

    // Keep the panel definitively hidden on load even when responsive display classes are present.
    if (this.panelElement) {
      this.panelElement.style.display = "none"
      this.panelElement.setAttribute("aria-hidden", "true")
      this.setPanelInteractivity(false)
    }

    this.syncFormFields(this.committed)
    this.syncTriggerValue(this.committed)
  }

  disconnect() {
    this.close()
    this.restorePanelParent()
    this.removeGlobalListeners()
  }

  toggle(event) {
    event.preventDefault()

    if (event.type === "keydown") {
      const key = event.key
      if (key !== "Enter" && key !== " ") {
        return
      }
    }

    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.panelElement) {
      return
    }

    this.mountPanelToBody()
    this.setPanelInteractivity(true)
    this.isOpen = true
    this.panelElement.style.display = ""
    this.panelElement.classList.remove("hidden")
    this.panelElement.setAttribute("aria-hidden", "false")
    this.triggerTarget?.setAttribute("aria-expanded", "true")
    this.draft = { ...this.committed }
    this.draftPresetKey = this.committedPresetKey
    this.viewMode = this.defaultViewMode()
    this.render()
    this.positionPanel()
    this.addGlobalListeners()
  }

  close() {
    if (!this.panelElement) {
      return
    }

    if (this.panelElement.contains(document.activeElement)) {
      this.triggerTarget?.focus()
    }

    this.isOpen = false
    this.panelElement.classList.add("hidden")
    this.panelElement.style.display = "none"
    this.panelElement.setAttribute("aria-hidden", "true")
    this.triggerTarget?.setAttribute("aria-expanded", "false")
    this.setPanelInteractivity(false)
    this.removeGlobalListeners()
    this.restorePanelParent()
  }

  setPanelInteractivity(isOpen) {
    if (!this.panelElement) {
      return
    }

    this.panelElement.inert = !isOpen
  }

  cancel(event) {
    event.preventDefault()
    this.draft = { ...this.committed }
    this.draftPresetKey = this.committedPresetKey
    this.viewMode = this.defaultViewMode()
    this.render()
    this.close()
  }

  apply(event) {
    event.preventDefault()

    const normalizedDraft = this.normalizeDraftForApply(this.draft)
    if (!normalizedDraft) {
      this.close()
      return
    }

    this.committed = normalizedDraft
    this.committedPresetKey = this.draftPresetKey || this.presetKeyForRange(normalizedDraft)
    this.draftPresetKey = this.committedPresetKey
    this.syncFormFields(this.committed)
    this.syncTriggerValue(this.committed)
    this.close()
  }

  requestApply(event) {
    event.preventDefault()
    this.apply(event)
  }

  normalizeDraftForApply(state) {
    if (!state.start) {
      return null
    }

    if (!this.rangeValue) {
      return { start: state.start, end: null }
    }

    return {
      start: state.start,
      end: state.end || state.start
    }
  }

  previousMonth(event) {
    event.preventDefault()
    this.visibleMonth = new Date(this.visibleMonth.getFullYear(), this.visibleMonth.getMonth() - 1, 1)
    this.renderCalendar()
    this.positionPanel()
  }

  nextMonth(event) {
    event.preventDefault()
    this.visibleMonth = new Date(this.visibleMonth.getFullYear(), this.visibleMonth.getMonth() + 1, 1)
    this.renderCalendar()
    this.positionPanel()
  }

  selectPreset(event) {
    event.preventDefault()

    const preset = String(event?.params?.preset || "")
    this.applyPreset(preset)
  }

  applyPreset(preset) {
    const range = this.computePresetRange(preset)
    if (!range) {
      return
    }

    this.draft = this.clipRange(range)

    if (!this.rangeValue) {
      this.draft.end = null
    }

    this.draftPresetKey = preset

    this.visibleMonth = new Date(this.draft.start || this.today)
    this.render()
  }

  selectDay(event) {
    event.preventDefault()

    const isoDate = String(event?.params?.date || "")
    this.applyDaySelection(isoDate)
  }

  applyDaySelection(isoDate) {
    if (!isoDate) {
      return
    }

    const selected = this.parseIso(isoDate)
    if (!selected || !this.isSelectable(selected)) {
      return
    }

    if (!this.rangeValue) {
      this.draft = { start: selected, end: null }
      this.draftPresetKey = null
      this.render()
      return
    }

    if (!this.draft.start || (this.draft.start && this.draft.end)) {
      this.draft = { start: selected, end: null }
      this.draftPresetKey = null
      this.render()
      return
    }

    if (selected < this.draft.start) {
      this.draft = { start: selected, end: this.draft.start }
    } else {
      this.draft = { start: this.draft.start, end: selected }
    }

    this.draftPresetKey = null

    this.render()
  }

  addGlobalListeners() {
    document.addEventListener("click", this.handleDocumentClick, true)
    document.addEventListener("keydown", this.handleEscape, true)
    this.panelElement?.addEventListener("click", this.handlePanelClick, true)
    window.addEventListener("resize", this.handleReposition)
    window.addEventListener("scroll", this.handleReposition, true)
  }

  removeGlobalListeners() {
    document.removeEventListener("click", this.handleDocumentClick, true)
    document.removeEventListener("keydown", this.handleEscape, true)
    this.panelElement?.removeEventListener("click", this.handlePanelClick, true)
    window.removeEventListener("resize", this.handleReposition)
    window.removeEventListener("scroll", this.handleReposition, true)
  }

  handlePanelClick(event) {
    const commandElement = this.findCommandElement(event)

    if (!commandElement) {
      return
    }

    const command = String(commandElement.dataset.flatPackDatePickerCommand || "")

    switch (command) {
      case "previous-month":
        this.previousMonth(event)
        break
      case "next-month":
        this.nextMonth(event)
        break
      case "cancel":
        this.cancel(event)
        break
      case "apply":
        this.apply(event)
        break
      case "preset":
        this.applyPreset(String(commandElement.dataset.flatPackDatePickerPreset || ""))
        break
      case "show-calendar":
        this.showCalendar(event)
        break
      case "show-ranges":
        this.showRanges(event)
        break
      case "day":
        this.applyDaySelection(String(commandElement.dataset.flatPackDatePickerDate || ""))
        break
      default:
        break
    }
  }

  findCommandElement(event) {
    if (event.target instanceof Element) {
      const fromTarget = event.target.closest("[data-flat-pack-date-picker-command]")
      if (fromTarget) {
        return fromTarget
      }
    }

    const path = typeof event.composedPath === "function" ? event.composedPath() : []
    for (const node of path) {
      if (node instanceof Element && node.hasAttribute("data-flat-pack-date-picker-command")) {
        return node
      }
    }

    return null
  }

  handleDocumentClick(event) {
    if (!this.isOpen) {
      return
    }

    const clickedInsideTrigger = this.element.contains(event.target)
    const clickedInsidePanel = this.panelElement && this.panelElement.contains(event.target)
    const clickedInside = clickedInsideTrigger || clickedInsidePanel
    if (!clickedInside) {
      this.close()
    }
  }

  handleReposition() {
    if (!this.isOpen) {
      return
    }

    this.renderViewMode()
    this.positionPanel()
  }

  handleEscape(event) {
    if (!this.isOpen || event.key !== "Escape") {
      return
    }

    event.preventDefault()
    this.cancel(event)
    this.triggerTarget?.focus()
  }

  render() {
    this.renderViewMode()
    this.renderListOptionSelection()
    this.renderCalendar()
    this.renderSummary()
    this.syncTriggerValue(this.committed)

    if (this.isOpen) {
      this.positionPanel()
    }
  }

  mountPanelToBody() {
    if (!this.panelElement || this.panelElement.parentNode === document.body) {
      return
    }

    this.panelOriginalParent = this.panelElement.parentNode
    this.panelOriginalNextSibling = this.panelElement.nextSibling
    document.body.appendChild(this.panelElement)
  }

  restorePanelParent() {
    if (!this.panelElement || !this.panelOriginalParent) {
      return
    }

    if (this.panelOriginalNextSibling && this.panelOriginalNextSibling.parentNode === this.panelOriginalParent) {
      this.panelOriginalParent.insertBefore(this.panelElement, this.panelOriginalNextSibling)
    } else {
      this.panelOriginalParent.appendChild(this.panelElement)
    }

    this.panelOriginalParent = null
    this.panelOriginalNextSibling = null
  }

  positionPanel() {
    if (!this.panelElement || !this.hasTriggerTarget) {
      return
    }

    if (this.isMobileViewport()) {
      this.panelElement.style.position = "fixed"
      this.panelElement.style.inset = "0"
      this.panelElement.style.left = "0"
      this.panelElement.style.top = "0"
      this.panelElement.style.width = "100vw"
      this.panelElement.style.maxWidth = "100vw"
      this.panelElement.style.height = "100dvh"
      this.panelElement.style.maxHeight = "100dvh"
      return
    }

    this.panelElement.style.inset = ""
    this.panelElement.style.height = ""
    this.panelElement.style.maxHeight = ""

    const triggerRect = this.triggerTarget.getBoundingClientRect()
    const panelRect = this.panelElement.getBoundingClientRect()
    const width = Math.min(panelRect.width, window.innerWidth - (this.viewportPadding * 2))

    const preferredBelow = triggerRect.bottom + this.spacing
    const preferredAbove = triggerRect.top - panelRect.height - this.spacing
    const canFitBelow = preferredBelow + panelRect.height <= window.innerHeight - this.viewportPadding
    const top = canFitBelow ? preferredBelow : preferredAbove

    const centeredLeft = triggerRect.left + (triggerRect.width / 2) - (width / 2)
    const clampedLeft = Math.max(this.viewportPadding, Math.min(centeredLeft, window.innerWidth - width - this.viewportPadding))
    const clampedTop = Math.max(this.viewportPadding, Math.min(top, window.innerHeight - panelRect.height - this.viewportPadding))

    this.panelElement.style.position = "fixed"
    this.panelElement.style.left = `${clampedLeft}px`
    this.panelElement.style.top = `${clampedTop}px`
    this.panelElement.style.width = `${width}px`
    this.panelElement.style.maxWidth = `${window.innerWidth - (this.viewportPadding * 2)}px`
  }

  renderCalendar() {
    if (!this.monthLabelElement || !this.calendarGridElement) {
      return
    }

    const monthFormatter = new Intl.DateTimeFormat(undefined, { month: "long", year: "numeric" })
    this.monthLabelElement.textContent = monthFormatter.format(this.visibleMonth)

    const firstOfMonth = new Date(this.visibleMonth.getFullYear(), this.visibleMonth.getMonth(), 1)
    const firstWeekday = (firstOfMonth.getDay() + 6) % 7
    const daysInMonth = new Date(this.visibleMonth.getFullYear(), this.visibleMonth.getMonth() + 1, 0).getDate()

    const cells = []

    for (let i = 0; i < firstWeekday; i += 1) {
      cells.push('<span class="h-9 w-9"></span>')
    }

    for (let day = 1; day <= daysInMonth; day += 1) {
      const date = new Date(this.visibleMonth.getFullYear(), this.visibleMonth.getMonth(), day)
      const iso = this.toIso(date)
      const selectable = this.isSelectable(date)
      const selected = this.isSelected(date)
      const inRange = this.isWithinRange(date)
      const isRangeStart = this.isRangeStart(date)
      const isRangeEnd = this.isRangeEnd(date)

      const classes = [
        "h-9",
        "w-9",
        "inline-flex",
        "items-center",
        "justify-center",
        "text-center",
        "leading-none",
        "rounded-md",
        "text-sm",
        "transition-colors",
        "duration-base",
        "focus:outline-none",
        "focus:ring-2",
        "focus:ring-ring"
      ]

      if (selected) {
        classes.push(
          "w-full",
          "justify-self-stretch",
          "bg-[var(--button-primary-background-color)]",
          "text-[var(--button-primary-text-color)]"
        )

        if (isRangeStart && !isRangeEnd) {
          classes.push("rounded-r-none", "rounded-l-md")
        } else if (isRangeEnd && !isRangeStart) {
          classes.push("rounded-l-none", "rounded-r-md")
        }
      } else if (inRange) {
        classes.push(
          "w-full",
          "justify-self-stretch",
          "rounded-none",
          "bg-[var(--button-primary-background-color)]/20",
          "text-[var(--button-default-text-color)]"
        )
      } else {
        classes.push(
          "bg-[var(--button-default-background-color)]",
          "text-[var(--button-default-text-color)]",
          "hover:bg-[var(--button-default-hover-background-color)]"
        )
      }

      if (!selectable) {
        classes.push("cursor-not-allowed", "opacity-40", "hover:bg-transparent")
      }

      const disabled = selectable ? "" : "disabled"

      cells.push(`
        <button
          type="button"
          class="${classes.join(" ")}"
          ${disabled}
          data-flat-pack-date-picker-command="day"
          data-flat-pack-date-picker-date="${iso}"
        >${day}</button>
      `)
    }

    this.calendarGridElement.innerHTML = cells.join("")
  }

  renderSummary() {
    if (!this.summaryElement) {
      return
    }

    const label = this.displayValue(this.draft, this.draftPresetKey)
    this.summaryElement.textContent = label || "Select a date from calendar or use a quick range preset."
  }

  initialVisibleMonth() {
    const seed = this.parseIso(this.startValue) || this.parseIso(this.valueValue) || this.today
    return new Date(seed.getFullYear(), seed.getMonth(), 1)
  }

  initialCommittedValues() {
    if (this.rangeValue) {
      return {
        start: this.parseIso(this.startValue),
        end: this.parseIso(this.endValue)
      }
    }

    return {
      start: this.parseIso(this.valueValue),
      end: null
    }
  }

  selectionComplete(state) {
    if (!state.start) {
      return false
    }

    if (!this.rangeValue) {
      return true
    }

    return Boolean(state.end)
  }

  displayValue(state, presetKey = null) {
    if (!state.start) {
      return ""
    }

    if (presetKey && this.selectionComplete(state)) {
      const presetLabel = this.labelForPreset(presetKey)
      if (presetLabel) {
        return presetLabel
      }
    }

    const start = this.toIso(state.start)
    if (!this.rangeValue) {
      return start
    }

    if (!state.end) {
      return `${start} to …`
    }

    return `${start} to ${this.toIso(state.end)}`
  }

  syncTriggerValue(state) {
    if (!this.hasTriggerTarget) {
      return
    }

    const presetKey = this.committedPresetKey
    this.triggerTarget.value = this.displayValue(state, presetKey)
  }

  initialPresetKey() {
    if (this.hasPresetKeyValue && this.presetKeyValue) {
      return this.presetKeyValue
    }

    return this.presetKeyForRange(this.committed)
  }

  labelForPreset(key) {
    if (!key || key === "pick_in_calendar") {
      return null
    }

    const labels = this.hasPresetLabelsValue ? this.presetLabelsValue : {}
    const label = labels[key]
    return typeof label === "string" && label.length > 0 ? label : null
  }

  presetKeyForRange(state) {
    if (!this.selectionComplete(state)) {
      return null
    }

    const labels = this.hasPresetLabelsValue ? this.presetLabelsValue : {}
    const keys = Object.keys(labels)

    for (const key of keys) {
      const presetRange = this.computePresetRange(key)
      if (!presetRange) {
        continue
      }

      const clippedPreset = this.clipRange(presetRange)
      if (this.rangesEqual(clippedPreset, state)) {
        return key
      }
    }

    return null
  }

  rangesEqual(a, b) {
    const aStart = a?.start ? this.toIso(a.start) : null
    const aEnd = a?.end ? this.toIso(a.end) : null
    const bStart = b?.start ? this.toIso(b.start) : null
    const bEnd = b?.end ? this.toIso(b.end) : null

    return aStart === bStart && aEnd === bEnd
  }

  syncFormFields(state) {
    if (this.rangeValue) {
      if (this.hasRangeStartFieldTarget) {
        this.rangeStartFieldTarget.value = state.start ? this.toIso(state.start) : ""
      }

      if (this.hasRangeEndFieldTarget) {
        this.rangeEndFieldTarget.value = state.end ? this.toIso(state.end) : ""
      }

      return
    }

    if (this.hasSingleFieldTarget) {
      this.singleFieldTarget.value = state.start ? this.toIso(state.start) : ""
    }
  }

  computePresetRange(key) {
    const today = this.today

    switch (key) {
      case "today":
        return { start: today, end: today }
      case "yesterday": {
        const yesterday = this.addDays(today, -1)
        return { start: yesterday, end: yesterday }
      }
      case "last_3_days":
        return { start: this.addDays(today, -2), end: today }
      case "this_week": {
        const start = this.startOfWeek(today)
        return { start, end: today }
      }
      case "last_week": {
        const thisWeekStart = this.startOfWeek(today)
        const end = this.addDays(thisWeekStart, -1)
        const start = this.startOfWeek(end)
        return { start, end }
      }
      case "this_month": {
        const start = new Date(today.getFullYear(), today.getMonth(), 1)
        return { start, end: today }
      }
      case "last_month": {
        const start = new Date(today.getFullYear(), today.getMonth() - 1, 1)
        const end = new Date(today.getFullYear(), today.getMonth(), 0)
        return { start, end }
      }
      case "this_year": {
        const start = new Date(today.getFullYear(), 0, 1)
        return { start, end: today }
      }
      case "last_year": {
        const start = new Date(today.getFullYear() - 1, 0, 1)
        const end = new Date(today.getFullYear() - 1, 11, 31)
        return { start, end }
      }
      default:
        return null
    }
  }

  clipRange(range) {
    const min = this.parseIso(this.minValue)
    const max = this.parseIso(this.maxValue)

    let start = range.start
    let end = range.end

    if (min) {
      if (start && start < min) {
        start = min
      }
      if (end && end < min) {
        end = min
      }
    }

    if (max) {
      if (start && start > max) {
        start = max
      }
      if (end && end > max) {
        end = max
      }
    }

    if (end && start && end < start) {
      end = start
    }

    return { start, end }
  }

  isSelectable(date) {
    const min = this.parseIso(this.minValue)
    const max = this.parseIso(this.maxValue)

    if (min && date < min) {
      return false
    }

    if (max && date > max) {
      return false
    }

    return true
  }

  isSelected(date) {
    const iso = this.toIso(date)
    const start = this.draft.start ? this.toIso(this.draft.start) : null
    const end = this.draft.end ? this.toIso(this.draft.end) : null

    return iso === start || iso === end
  }

  isWithinRange(date) {
    if (!this.draft.start || !this.draft.end) {
      return false
    }

    return date > this.draft.start && date < this.draft.end
  }

  isRangeStart(date) {
    if (!this.draft.start) {
      return false
    }

    return this.toIso(date) === this.toIso(this.draft.start)
  }

  isRangeEnd(date) {
    if (!this.draft.end) {
      return false
    }

    return this.toIso(date) === this.toIso(this.draft.end)
  }

  startOfWeek(date) {
    const day = (date.getDay() + 6) % 7
    return this.addDays(date, -day)
  }

  addDays(date, offset) {
    const clone = new Date(date)
    clone.setDate(clone.getDate() + offset)
    return this.startOfDay(clone)
  }

  parseIso(value) {
    if (!value) {
      return null
    }

    const text = String(value).trim()
    if (!/^\d{4}-\d{2}-\d{2}$/.test(text)) {
      return null
    }

    const [year, month, day] = text.split("-").map(Number)
    return this.startOfDay(new Date(year, month - 1, day))
  }

  toIso(date) {
    return [
      String(date.getFullYear()).padStart(4, "0"),
      String(date.getMonth() + 1).padStart(2, "0"),
      String(date.getDate()).padStart(2, "0")
    ].join("-")
  }

  startOfDay(date) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate())
  }

  showCalendar(event) {
    event.preventDefault()
    this.draftPresetKey = "pick_in_calendar"
    this.viewMode = "calendar"
    this.renderViewMode()
    this.renderListOptionSelection()
  }

  showRanges(event) {
    event.preventDefault()
    this.viewMode = "list"
    this.renderViewMode()
  }

  defaultViewMode() {
    return this.isMobileViewport() ? "list" : "calendar"
  }

  isMobileViewport() {
    return window.matchMedia("(max-width: 767px)").matches
  }

  renderViewMode() {
    if (!this.panelElement) {
      return
    }

    if (!this.listViewElement || !this.calendarViewElement) {
      return
    }

    if (!this.isMobileViewport()) {
      this.listViewElement.classList.remove("hidden")
      this.calendarViewElement.classList.remove("hidden")
      return
    }

    const showCalendar = this.viewMode === "calendar"
    this.listViewElement.classList.toggle("hidden", showCalendar)
    this.calendarViewElement.classList.toggle("hidden", !showCalendar)
  }

  renderListOptionSelection() {
    if (!this.panelElement) {
      return
    }

    const optionButtons = this.panelElement.querySelectorAll(
      '[data-flat-pack-date-picker-command="preset"], [data-flat-pack-date-picker-command="show-calendar"]'
    )

    const selectedClasses = [
      "bg-[var(--button-primary-background-color)]",
      "text-[var(--button-primary-text-color)]",
      "hover:bg-[var(--button-primary-hover-background-color)]"
    ]

    optionButtons.forEach((button) => {
      const command = button.dataset.flatPackDatePickerCommand
      const key = command === "preset" ? String(button.dataset.flatPackDatePickerPreset || "") : "pick_in_calendar"
      const selected = this.draftPresetKey === key

      selectedClasses.forEach((className) => {
        button.classList.toggle(className, selected)
      })
    })
  }
}
