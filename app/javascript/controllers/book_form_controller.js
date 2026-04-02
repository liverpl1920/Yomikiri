import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['totalPages', 'targetPages', 'deadline', 'quotaDisplay']

  connect () {
    this.calculateQuota()
  }

  syncTargetPages () {
    const total = parseInt(this.totalPagesTarget.value, 10)
    if (!isNaN(total) && total > 0) {
      const current = parseInt(this.targetPagesTarget.value, 10)
      // target_pages が未入力、または total_pages と同じ値だった場合のみ自動入力
      if (isNaN(current) || current <= 0 || current === this._previousTotal) {
        this.targetPagesTarget.value = total
      }
      this._previousTotal = total
    }
    this.calculateQuota()
  }

  calculateQuota () {
    const targetPages = parseInt(this.targetPagesTarget.value, 10)
    const deadlineValue = this.deadlineTarget.value
    const display = this.quotaDisplayTarget

    if (isNaN(targetPages) || targetPages <= 0 || !deadlineValue) {
      this._showPlaceholder(display)
      return
    }

    const deadline = new Date(deadlineValue)
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    deadline.setHours(0, 0, 0, 0)

    if (deadline < today) {
      this._showError(display, '読了期限は今日以降の日付を指定してください')
      return
    }

    const remainingDays = Math.floor((deadline - today) / (1000 * 60 * 60 * 24)) + 1
    const quota = Math.ceil(targetPages / remainingDays)

    this._showQuota(display, quota, remainingDays)
  }

  _showPlaceholder (display) {
    display.querySelector('.quota-preview__number').textContent = '-'
    display.querySelector('.quota-preview__note').textContent =
      '読了期限・ページ数を入力すると自動計算されます'
    display.querySelector('.quota-preview__note').classList.remove('quota-preview__note--error')
  }

  _showError (display, message) {
    display.querySelector('.quota-preview__number').textContent = '-'
    const note = display.querySelector('.quota-preview__note')
    note.textContent = message
    note.classList.add('quota-preview__note--error')
  }

  _showQuota (display, quota, remainingDays) {
    display.querySelector('.quota-preview__number').textContent = quota
    const note = display.querySelector('.quota-preview__note')
    note.textContent = `残り ${remainingDays} 日で読み切るには、1日 ${quota} ページ必要です`
    note.classList.remove('quota-preview__note--error')
  }
}
