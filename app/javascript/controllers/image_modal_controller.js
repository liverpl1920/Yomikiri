import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open() {
    if (this.hasDialogTarget) {
      this.dialogTarget.showModal()
      document.body.style.overflow = "hidden"
    }
  }

  close() {
    if (this.hasDialogTarget) {
      this.dialogTarget.close()
      document.body.style.overflow = ""
    }
  }

  closeOnBackdrop(event) {
    if (this.hasDialogTarget && event.target === this.dialogTarget) {
      this.close()
    }
  }

  disconnect() {
    document.body.style.overflow = ""
  }
}
