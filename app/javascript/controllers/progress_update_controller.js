import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['advancedSection']

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
