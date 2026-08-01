import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "extendOverlay", "retireOverlay"]

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

  openExtend() {
    this.extendOverlayTarget.removeAttribute("hidden")
    this.extendOverlayTarget.setAttribute("aria-hidden", "false")
  }

  closeExtend() {
    this.extendOverlayTarget.setAttribute("hidden", "")
    this.extendOverlayTarget.setAttribute("aria-hidden", "true")
  }

  closeExtendOnBackdrop(event) {
    if (event.target === this.extendOverlayTarget) {
      this.closeExtend()
    }
  }

  openRetire() {
    this.retireOverlayTarget.removeAttribute("hidden")
    this.retireOverlayTarget.setAttribute("aria-hidden", "false")
  }

  closeRetire() {
    this.retireOverlayTarget.setAttribute("hidden", "")
    this.retireOverlayTarget.setAttribute("aria-hidden", "true")
  }

  closeRetireOnBackdrop(event) {
    if (event.target === this.retireOverlayTarget) {
      this.closeRetire()
    }
  }
}
