import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['textarea', 'color']

  insertBold() {
    this.wrapSelection('**', '**', '強調したいテキスト')
  }

  insertColor() {
    const color = this.hasColorTarget ? this.colorTarget.value : '#dc2626'
    this.wrapSelection(`[color=${color}]`, '[/color]', '色付きテキスト')
  }

  wrapSelection(prefix, suffix, placeholder) {
    if (!this.hasTextareaTarget) return

    const input = this.textareaTarget
    const start = input.selectionStart ?? 0
    const end = input.selectionEnd ?? 0
    const selected = input.value.slice(start, end)
    const insertText = `${prefix}${selected || placeholder}${suffix}`

    input.setRangeText(insertText, start, end, 'end')
    input.focus()
    input.dispatchEvent(new Event('input', { bubbles: true }))
  }
}