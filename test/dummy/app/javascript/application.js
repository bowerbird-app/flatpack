// Configure your import map in config/importmap.rb.

import "@hotwired/turbo-rails"
import "tiptap_demo_addons"
import "controllers"
import { initLocalTimes } from "flat_pack/local_time"

document.addEventListener("DOMContentLoaded", () => {
  initLocalTimes()
})

document.addEventListener("turbo:load", () => {
  initLocalTimes()
})
