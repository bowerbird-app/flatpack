import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Apply saved theme on page load
    const savedTheme = localStorage.getItem('flatpack-theme')
    if (savedTheme && savedTheme !== 'system') {
      document.documentElement.setAttribute('data-theme', savedTheme)
    }
  }

  switch(event) {
    const themeValue = event.currentTarget.dataset.themeValue
    
    if (themeValue === 'system') {
      // Remove data-theme attribute to use system preference
      document.documentElement.removeAttribute('data-theme')
      localStorage.removeItem('flatpack-theme')
    } else {
      // Set explicit theme
      document.documentElement.setAttribute('data-theme', themeValue)
      localStorage.setItem('flatpack-theme', themeValue)
    }
  }
}