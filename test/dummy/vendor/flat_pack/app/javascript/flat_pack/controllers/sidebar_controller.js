import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleSection(event) {
    const button = event.currentTarget
    const itemsList = button.nextElementSibling
    const chevron = button.querySelector("svg")
    
    if (itemsList) {
      itemsList.classList.toggle("hidden")
    }
    
    if (chevron) {
      chevron.classList.toggle("rotate-180")
    }
  }
}
