import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleSection(event) {
    event.preventDefault()
    
    const button = event.currentTarget
    const itemsList = button.nextElementSibling
    const chevron = button.querySelector("svg")

    if (!itemsList) return

    // Toggle visibility
    itemsList.classList.toggle("hidden")

    // Rotate chevron
    if (chevron) {
      chevron.classList.toggle("rotate-180")
    }
  }
}
