import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    const isOpen = this.menuTarget.classList.toggle("dropdown__menu--open")
    this.element.querySelector(".dropdown__trigger")?.setAttribute("aria-expanded", isOpen)
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.remove("dropdown__menu--open")
      this.element.querySelector(".dropdown__trigger")?.setAttribute("aria-expanded", "false")
    }
  }
}
