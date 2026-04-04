import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['duration', 'link']
  static values = { title: String, description: String }

  connect () {
    this.updateLink()
  }

  updateLink () {
    this.linkTarget.href = this.buildUrl()
  }

  open (event) {
    event.preventDefault()
    window.open(this.buildUrl(), '_blank', 'noopener,noreferrer')
  }

  buildUrl () {
    const durationMinutes = this.selectedDuration()
    const now = new Date()
    const end = new Date(now.getTime() + durationMinutes * 60 * 1000)
    const fmt = d => d.toISOString().replace(/[-:]/g, '').split('.')[0] + 'Z'
    const params = new URLSearchParams({
      action: 'TEMPLATE',
      text: this.titleValue,
      details: this.descriptionValue,
      dates: `${fmt(now)}/${fmt(end)}`
    })
    return `https://calendar.google.com/calendar/render?${params}`
  }

  selectedDuration () {
    const selected = this.durationTargets.find(input => input.checked)
    return selected ? parseInt(selected.value, 10) : 30
  }
}
