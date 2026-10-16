import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration } from "controllers/flat_pack/reduced_motion"

const EASING = {
  standard: "cubic-bezier(0.2, 0, 0, 1)",
  enter: "cubic-bezier(0.05, 0.7, 0.1, 1)",
  exit: "cubic-bezier(0.3, 0, 1, 1)",
  linear: "linear"
}

const EASING_TOKEN = {
  standard: "--easing-standard",
  enter: "--easing-enter",
  exit: "--easing-exit"
}

const STROKE_SELECTOR = "path, line, polyline, circle, ellipse, rect"

export default class extends Controller {
  static values = {
    definition: { type: Object, default: {} },
    state: { type: String, default: "idle" },
    trigger: { type: String, default: "mount" }
  }

  #animations = []

  connect() {
    this.playBound = () => this.play()
    if (this.triggerValue === "hover") {
      this.element.addEventListener("pointerenter", this.playBound)
    } else if (this.triggerValue === "click") {
      this.element.addEventListener("click", this.playBound)
    } else if (this.triggerValue === "mount") {
      this.play()
    }
  }

  disconnect() {
    this.element.removeEventListener("pointerenter", this.playBound)
    this.element.removeEventListener("click", this.playBound)
    this.stop()
  }

  setState(stateOrEvent) {
    const name = typeof stateOrEvent === "string" ? stateOrEvent : stateOrEvent?.params?.state
    if (!name) return

    this.stateValue = name
    this.play()
  }

  play() {
    this.stop()
    if (prefersReducedMotion()) return

    const tracks = this.#tracks()
    const paired = new Set()
    tracks.forEach((track, index) => {
      if (paired.has(index)) return

      const partner = this.#axisPartner(tracks, index)
      if (partner == null) {
        this.#playTrack(track)
        return
      }

      paired.add(partner)
      this.#playAxisPair(track, tracks[partner])
    })
  }

  stop() {
    this.#animations.forEach((animation) => animation.cancel())
    this.#animations = []
  }

  pause() {
    this.#animations.forEach((animation) => animation.pause())
  }

  resume() {
    this.#animations.forEach((animation) => {
      if (animation.playState === "paused") animation.play()
    })
  }

  reset() {
    this.stop()
    this.#painted().forEach((node) => {
      node.style.translate = ""
      node.style.scale = ""
      node.style.rotate = ""
      node.style.opacity = ""
      node.style.strokeDashoffset = ""
      node.style.strokeDasharray = ""
    })
  }

  #tracks() {
    const states = this.definitionValue?.states || {}
    return states[this.stateValue]?.tracks || []
  }

  // scaleX and scaleY share one CSS `scale`. Same for translate. Pair them
  // when the timing matches so the second track does not replace the first.
  #axisPartner(tracks, index) {
    const track = tracks[index]
    const mate = { scaleX: "scaleY", scaleY: "scaleX", translateX: "translateY", translateY: "translateX" }[track.property]
    if (!mate) return null

    const partner = tracks.findIndex((other, otherIndex) =>
      otherIndex > index &&
      other.part === track.part &&
      other.property === mate &&
      other.duration === track.duration &&
      other.delay === track.delay &&
      other.easing === track.easing &&
      other.iterations === track.iterations &&
      other.keyframes.length === track.keyframes.length
    )
    return partner === -1 ? null : partner
  }

  #playAxisPair(track, other) {
    const scale = track.property.startsWith("scale")
    const targets = this.#targets(track.part)
    targets.forEach((target) => {
      const frames = track.keyframes.map((entry, index) => {
        const own = this.#number(entry)
        const mate = this.#number(other.keyframes[index])
        const x = track.property.endsWith("X") ? own : mate
        const y = track.property.endsWith("Y") ? own : mate
        const frame = scale ? { scale: `${x} ${y}` } : { translate: `${x}px ${y}px` }
        const offset = entry && typeof entry === "object" ? entry.offset : undefined
        if (offset != null) frame.offset = offset
        return frame
      })
      this.#animations.push(target.animate(frames, this.#timing(track)))
    })
  }

  #number(entry) {
    return entry && typeof entry === "object" ? entry.value : entry
  }

  #playTrack(track, attempt = 0) {
    const targets = this.#targets(track.part)
    if (track.part === "strokes" && targets.length === 0 && attempt < 5) {
      const schedule = globalThis.requestAnimationFrame || ((callback) => callback())
      schedule(() => this.#playTrack(track, attempt + 1))
      return
    }

    targets.forEach((target) => {
      const animation = target.animate(this.#keyframes(track, target), this.#timing(track))
      this.#animations.push(animation)
    })
  }

  #targets(part) {
    if (part === "root") return [this.element]
    if (part === "strokes") return [...this.element.querySelectorAll(STROKE_SELECTOR)]

    const name = globalThis.CSS?.escape ? CSS.escape(part) : part
    return [...this.element.querySelectorAll(`[data-part="${name}"]`)]
  }

  #keyframes(track, target) {
    return track.keyframes.map((entry) => {
      const value = entry && typeof entry === "object" ? entry.value : entry
      const offset = entry && typeof entry === "object" ? entry.offset : undefined
      const frame = this.#frame(track.property, value, target)
      if (offset != null) frame.offset = offset
      return frame
    })
  }

  #frame(property, value, target) {
    switch (property) {
      case "translateX":
        return { translate: `${value}px 0px` }
      case "translateY":
        return { translate: `0px ${value}px` }
      case "scaleX":
        return { scale: `${value} 1` }
      case "scaleY":
        return { scale: `1 ${value}` }
      case "rotate":
        return { rotate: `${value}deg` }
      case "opacity":
        return { opacity: value }
      case "strokeDashoffset":
        return { strokeDashoffset: value === "length" ? this.#strokeLength(target) : value }
      default:
        return {}
    }
  }

  #strokeLength(target) {
    const length = typeof target.getTotalLength === "function" ? target.getTotalLength() : 0
    target.style.strokeDasharray = `${length}`
    return length
  }

  #timing(track) {
    return {
      duration: this.#milliseconds(track.duration),
      delay: track.delay || 0,
      easing: this.#easing(track.easing),
      iterations: track.iterations === "infinite" ? Infinity : track.iterations,
      fill: "forwards"
    }
  }

  #milliseconds(value) {
    if (typeof value === "number") return value

    return motionDuration(String(value))
  }

  #easing(name) {
    const fallback = EASING[name] || EASING.standard
    const token = EASING_TOKEN[name]
    if (!token || typeof getComputedStyle !== "function" || !globalThis.document?.documentElement) return fallback

    const raw = getComputedStyle(document.documentElement).getPropertyValue(token).trim()
    return raw || fallback
  }

  #painted() {
    return [this.element, ...this.element.querySelectorAll(`[data-part], ${STROKE_SELECTOR}`)]
  }
}
