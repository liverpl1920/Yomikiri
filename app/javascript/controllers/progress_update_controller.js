import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['pagesRead', 'advancedSection']
  static values = { max: Number }

  increment () {
    const input = this.pagesReadTarget
    const current = parseInt(input.value, 10) || 0
    const max = this.maxValue
    if (current < max) {
      input.value = current + 1
    }
  }

  decrement () {
    const input = this.pagesReadTarget
    const current = parseInt(input.value, 10) || 0
    if (current > 1) {
      input.value = current - 1
    }
  }

  toggleAdvanced (event) {
    const button = event.currentTarget
    const section = this.advancedSectionTarget
    const isExpanded = button.getAttribute('aria-expanded') === 'true'

    button.setAttribute('aria-expanded', String(!isExpanded))
    section.hidden = isExpanded

    const icon = button.querySelector('.progress-update__toggle-icon')
    if (icon) {
      icon.textContent = isExpanded ? '▶' : '▼'
    }
  }
}
