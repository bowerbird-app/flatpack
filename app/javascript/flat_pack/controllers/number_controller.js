import { Controller } from "@hotwired/stimulus"
import { observeOnce, prefersReducedMotion, motionTokenMs } from "controllers/flat_pack/reduced_motion"

const EASE_FALLBACK = [0.05, 0.7, 0.1, 1]
const ZERO_DECIMAL_CURRENCIES = new Set(["JPY", "KRW", "VND"])

// Counts, rolls, or fades a number the first time it enters the viewport.
// The finished string stays in .fp-number__final for screen readers.
// Later value changes animate from the number on screen to the new one.
export default class extends Controller {
  static targets = ["stage", "final", "sizer"]

  static values = {
    value: Number,
    from: { type: Number, default: 0 },
    format: { type: String, default: "number" },
    currency: String,
    decimals: Number,
    prefix: String,
    suffix: String,
    duration: { type: String, default: "slow" },
    animate: { type: String, default: "count" },
    locale: String,
    fromText: String
  }

  connect() {
    this.current = this.fromValue
    this.goal = this.valueValue
    this.connected = true

    if (this.animateValue === "none" || prefersReducedMotion()) {
      this.element.classList.add("is-static")
      this.current = this.valueValue
      return
    }

    this.stopObserving = observeOnce(this.element, () => {
      if (this.stopped) return

      this.started = true
      const next = this.pendingTo ?? this.valueValue
      this.pendingTo = undefined
      this.play(this.fromValue, next)
    })
  }

  disconnect() {
    this.stopped = true
    this.stopObserving?.()
    this.stopObserving = null
    this.cancel()
  }

  valueValueChanged(next) {
    if (!this.connected || !Number.isFinite(next)) return

    const text = this.format(next)
    if (this.hasFinalTarget) this.finalTarget.textContent = text
    if (this.hasSizerTarget) this.sizerTarget.textContent = text

    if (this.element.classList.contains("is-static")) {
      this.current = next
      this.goal = next
      return
    }

    if (!this.started) {
      this.pendingTo = next
      return
    }

    if (next === this.goal) return

    this.play(this.current, next)
  }

  setValue(next) {
    const number = typeof next === "number" ? next : Number(String(next).trim())
    if (!Number.isFinite(number)) return

    this.valueValue = number
  }

  play(from, to) {
    this.cancel()
    const first = !this.played
    this.played = true
    this.goal = to
    const duration = motionTokenMs(this.durationValue)

    if (prefersReducedMotion() || duration === 0 || from === to) {
      this.showFinal(to)
      return
    }

    if (this.animateValue === "fade") this.playFade()
    else if (this.animateValue === "roll") this.playRoll(from, to, first)
    else this.playCount(from, to, duration)
  }

  showFinal(to) {
    this.current = to
    this.goal = to
    if (this.hasStageTarget && this.hasFinalTarget) {
      this.stageTarget.textContent = this.finalTarget.textContent
    }
    this.element.classList.remove("is-pending")
    this.element.classList.add("is-settled")
  }

  playFade() {
    if (this.hasStageTarget && this.hasFinalTarget) {
      this.stageTarget.textContent = this.finalTarget.textContent
    }
    this.element.classList.add("is-pending")
    this.element.classList.remove("is-settled")
    this.element.getBoundingClientRect()
    this.element.classList.remove("is-pending")
    this.element.classList.add("is-settled")
    this.current = this.goal
  }

  playCount(from, to, duration) {
    if (typeof this.element.animate !== "function") {
      this.showFinal(to)
      return
    }

    this.element.classList.remove("is-settled")
    const clock = this.element.animate([{ opacity: 1 }, { opacity: 1 }], {
      duration,
      easing: "linear",
      fill: "forwards"
    })
    this.clock = clock

    const step = () => {
      if (this.stopped || this.clock !== clock) return

      const elapsed = Number(clock.currentTime) || 0
      const t = Math.min(1, Math.max(0, elapsed / duration))
      this.renderCount(from, to, t)
      const paused = clock.playState === "paused"
      if (t < 1 || paused) this.frame = requestAnimationFrame(step)
    }

    this.frame = requestAnimationFrame(step)
  }

  renderCount(from, to, t) {
    if (t >= 1) {
      this.current = to
      if (this.hasStageTarget && this.hasFinalTarget) {
        this.stageTarget.textContent = this.finalTarget.textContent
      }
      this.element.classList.add("is-settled")
      return
    }

    this.element.classList.remove("is-settled")
    const shown = from + (to - from) * this.easeProgress(t)
    this.current = shown
    if (this.hasStageTarget) this.stageTarget.textContent = this.formatTick(shown)
  }

  playRoll(from, to, first) {
    const toCore = this.stripAffixes(this.hasFinalTarget ? this.finalTarget.textContent : this.core(to))
    const fromCore = first && this.fromTextValue ? this.fromTextValue : this.core(from)
    this.mountRoll(fromCore, toCore)
    this.current = to
  }

  mountRoll(fromCore, toCore) {
    if (!this.hasStageTarget) return

    const stage = this.stageTarget
    stage.replaceChildren()
    const roll = document.createElement("span")
    roll.className = "fp-number__roll"

    if (this.prefixValue) roll.append(this.affix(this.prefixValue))

    const columns = document.createElement("span")
    columns.className = "fp-number__columns"
    const strips = []

    this.columnsFor(fromCore, toCore).forEach((column) => {
      if (column.kind === "static") {
        const mark = document.createElement("span")
        mark.className = "fp-number__mark"
        mark.textContent = column.char
        columns.append(mark)
        return
      }

      const window = document.createElement("span")
      window.className = "fp-number__digit"
      const strip = document.createElement("span")
      strip.className = "fp-number__strip"
      for (let glyph = 0; glyph <= 9; glyph += 1) {
        const cell = document.createElement("span")
        cell.className = "fp-number__glyph"
        cell.textContent = String(glyph)
        strip.append(cell)
      }
      strip.style.transform = `translateY(calc(${column.from} * -1em))`
      strips.push([strip, column.to])
      window.append(strip)
      columns.append(window)
    })

    roll.append(columns)
    if (this.suffixValue) roll.append(this.affix(this.suffixValue))
    stage.append(roll)

    this.element.classList.add("is-pending")
    this.element.classList.remove("is-settled")
    this.element.getBoundingClientRect()
    this.element.classList.remove("is-pending")
    strips.forEach(([strip, digit]) => {
      strip.style.transform = `translateY(calc(${digit} * -1em))`
    })
    this.element.classList.add("is-settled")
  }

  affix(text) {
    const node = document.createElement("span")
    node.className = "fp-number__affix"
    node.textContent = text
    return node
  }

  columnsFor(fromText, toText) {
    const fromDigits = Array.from(fromText).filter((char) => this.digit(char))
    let cursor = fromDigits.length - Array.from(toText).filter((char) => this.digit(char)).length

    return Array.from(toText).map((char) => {
      if (!this.digit(char)) return { kind: "static", char }

      const from = cursor >= 0 && cursor < fromDigits.length ? Number(fromDigits[cursor]) : 0
      cursor += 1
      return { kind: "digit", from, to: Number(char) }
    })
  }

  digit(char) {
    return char >= "0" && char <= "9"
  }

  cancel() {
    if (this.frame != null) {
      cancelAnimationFrame(this.frame)
      this.frame = null
    }
    this.clock?.cancel()
    this.clock = null
  }

  format(number) {
    return `${this.prefixValue}${this.core(number)}${this.suffixValue}`
  }

  formatTick(number) {
    return `${this.prefixValue}${this.formatter(this.tickOptions()).format(number)}${this.suffixValue}`
  }

  core(number) {
    return this.formatter(this.formatOptions()).format(number)
  }

  stripAffixes(text) {
    let core = text ?? ""
    if (this.prefixValue && core.startsWith(this.prefixValue)) core = core.slice(this.prefixValue.length)
    if (this.suffixValue && core.endsWith(this.suffixValue)) core = core.slice(0, -this.suffixValue.length)
    return core
  }

  formatOptions() {
    const options = {}
    if (this.formatValue === "currency") {
      options.style = "currency"
      options.currency = this.currencyValue
    } else if (this.formatValue === "percent") {
      options.style = "percent"
    } else if (this.formatValue === "compact") {
      options.notation = "compact"
      options.compactDisplay = "short"
    }
    if (this.hasDecimalsValue) {
      options.minimumFractionDigits = this.decimalsValue
      options.maximumFractionDigits = this.decimalsValue
    }
    return options
  }

  tickOptions() {
    const options = this.formatOptions()
    if (this.hasDecimalsValue) return options

    if (this.formatValue === "currency") {
      const digits = ZERO_DECIMAL_CURRENCIES.has(this.currencyValue) ? 0 : 2
      options.minimumFractionDigits = digits
      options.maximumFractionDigits = digits
      return options
    }

    options.minimumFractionDigits = 0
    options.maximumFractionDigits = 0
    return options
  }

  formatter(options) {
    return new Intl.NumberFormat(this.localeValue || undefined, options)
  }

  easeProgress(t) {
    if (t <= 0) return 0
    if (t >= 1) return 1

    return this.easing()(t)
  }

  easing() {
    if (this.curve) return this.curve

    const [x1, y1, x2, y2] = this.readEase()
    this.curve = cubicBezier(x1, y1, x2, y2)
    return this.curve
  }

  readEase() {
    try {
      const raw = getComputedStyle(document.documentElement).getPropertyValue("--motion-ease-out")
      const match = /cubic-bezier\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*\)/.exec(raw)
      if (match) return match.slice(1).map(Number)
    } catch (_error) {
      return EASE_FALLBACK
    }

    return EASE_FALLBACK
  }
}

function cubicBezier(x1, y1, x2, y2) {
  const cx = 3 * x1
  const bx = 3 * (x2 - x1) - cx
  const ax = 1 - cx - bx
  const cy = 3 * y1
  const by = 3 * (y2 - y1) - cy
  const ay = 1 - cy - by

  const sampleX = (t) => ((ax * t + bx) * t + cx) * t
  const sampleY = (t) => ((ay * t + by) * t + cy) * t
  const sampleDX = (t) => (3 * ax * t + 2 * bx) * t + cx

  return (x) => {
    let t = x
    for (let i = 0; i < 8; i += 1) {
      const slope = sampleDX(t)
      if (Math.abs(slope) < 1e-6) break

      const error = sampleX(t) - x
      if (Math.abs(error) < 1e-6) break

      t -= error / slope
    }
    return sampleY(Math.min(1, Math.max(0, t)))
  }
}
