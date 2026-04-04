import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  open() {
    this.overlayTarget.removeAttribute("hidden")
    this.overlayTarget.setAttribute("aria-hidden", "false")
  }

  close() {
    this.overlayTarget.setAttribute("hidden", "")
    this.overlayTarget.setAttribute("aria-hidden", "true")
  }

  closeOnBackdrop(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }
}
