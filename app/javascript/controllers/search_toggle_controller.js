import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-toggle"
export default class extends Controller {
  static targets = ["form", "button"]
  static values = {
    active: { type: Boolean, default: false }
  }

  connect() {
    this.updateState()
  }

  toggle(event) {
    event.preventDefault()
    this.activeValue = !this.activeValue
  }

  activeValueChanged() {
    this.updateState()
  }

  updateState() {
    if (!this.hasFormTarget) return

    if (this.activeValue) {
      this.formTarget.classList.remove("books-index__search--hidden")
      this.formTarget.setAttribute("aria-hidden", "false")
      if (this.hasButtonTarget) {
        this.buttonTarget.setAttribute("aria-expanded", "true")
      }
    } else {
      this.formTarget.classList.add("books-index__search--hidden")
      this.formTarget.setAttribute("aria-hidden", "true")
      if (this.hasButtonTarget) {
        this.buttonTarget.setAttribute("aria-expanded", "false")
      }
    }
  }
}
