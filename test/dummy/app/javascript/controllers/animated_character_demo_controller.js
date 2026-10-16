import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  setState(event) {
    this.#motion(event).setState(event.params.state)
  }

  play(event) {
    this.#motion(event).play()
  }

  stop(event) {
    this.#motion(event).stop()
  }

  reset(event) {
    this.#motion(event).reset()
  }

  pause(event) {
    this.#motion(event).pause()
  }

  resume(event) {
    this.#motion(event).resume()
  }

  #motion(event) {
    const element = this.element.querySelector(event.params.selector || "#bot")
    return this.application.getControllerForElementAndIdentifier(element, "flat-pack--svg-motion")
  }
}
