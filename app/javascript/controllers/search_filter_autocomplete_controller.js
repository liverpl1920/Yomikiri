import { Controller } from '@hotwired/stimulus'

const DEBOUNCE_DELAY = 300
const MIN_QUERY_LENGTH = 1

export default class extends Controller {
  static targets = ['input', 'list']
  static values = { field: String }

  connect () {
    this._debounceTimer = null
    this._abortController = null
    this._latestQuery = ''
    this._activeIndex = -1
    this._candidates = []
    this._handleOutsideClick = this._onOutsideClick.bind(this)
    document.addEventListener('click', this._handleOutsideClick)
  }

  disconnect () {
    clearTimeout(this._debounceTimer)
    if (this._abortController) this._abortController.abort()
    document.removeEventListener('click', this._handleOutsideClick)
  }

  onInput () {
    clearTimeout(this._debounceTimer)
    const query = this.inputTarget.value.trim()
    this._latestQuery = query

    if (query.length < MIN_QUERY_LENGTH) {
      if (this._abortController) this._abortController.abort()
      this._closeList()
      return
    }

    this._debounceTimer = setTimeout(() => {
      this._fetchCandidates(query)
    }, DEBOUNCE_DELAY)
  }

  onKeydown (event) {
    if (!this._isListOpen()) return

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this._moveFocus(1)
        break
      case 'ArrowUp':
        event.preventDefault()
        this._moveFocus(-1)
        break
      case 'Enter':
        if (this._activeIndex >= 0 && this._candidates[this._activeIndex]) {
          event.preventDefault()
          this._selectCandidate(this._candidates[this._activeIndex])
        }
        break
      case 'Escape':
        this._closeList()
        break
    }
  }

  async _fetchCandidates (query) {
    if (this._abortController) this._abortController.abort()
    this._abortController = new AbortController()

    const field = this.fieldValue
    const url = `/books/suggestions?field=${encodeURIComponent(field)}&q=${encodeURIComponent(query)}`

    try {
      const res = await fetch(url, {
        headers: { Accept: 'application/json' },
        signal: this._abortController.signal
      })
      if (!res.ok) throw new Error('Network error')

      const data = await res.json()
      if (query !== this._latestQuery || query !== this.inputTarget.value.trim()) return

      if (data.error) {
        this._closeList()
        return
      }

      this._candidates = data.suggestions || []
      this._renderList(this._candidates)
    } catch (error) {
      if (error.name === 'AbortError') return
      this._closeList()
    }
  }

  _renderList (candidates) {
    const list = this.listTarget
    list.innerHTML = ''
    this._activeIndex = -1

    if (candidates.length === 0) {
      this._closeList()
      return
    }

    candidates.forEach((text, index) => {
      const li = document.createElement('li')
      li.className = 'search-filter-autocomplete__item'
      li.setAttribute('role', 'option')
      li.setAttribute('aria-selected', 'false')
      li.dataset.index = index

      const button = document.createElement('button')
      button.type = 'button'
      button.className = 'search-filter-autocomplete__button'
      button.textContent = text

      button.addEventListener('click', (event) => {
        event.stopPropagation()
        this._selectCandidate(text)
      })

      li.appendChild(button)
      list.appendChild(li)
    })

    list.classList.remove('search-filter-autocomplete__list--hidden')
    list.setAttribute('aria-expanded', 'true')
  }

  _selectCandidate (text) {
    this.inputTarget.value = text
    this._closeList()
  }

  _closeList () {
    const list = this.listTarget
    list.innerHTML = ''
    list.classList.add('search-filter-autocomplete__list--hidden')
    list.setAttribute('aria-expanded', 'false')
    this._activeIndex = -1
    this._candidates = []
  }

  _isListOpen () {
    return !this.listTarget.classList.contains('search-filter-autocomplete__list--hidden')
  }

  _moveFocus (direction) {
    const total = this._candidates.length
    if (total === 0) return

    this._activeIndex = (this._activeIndex + direction + total) % total
    this._updateActiveFocus()
  }

  _updateActiveFocus () {
    const items = this.listTarget.querySelectorAll('.search-filter-autocomplete__item')
    items.forEach((item, index) => {
      const isActive = index === this._activeIndex
      item.classList.toggle('search-filter-autocomplete__item--active', isActive)
      item.setAttribute('aria-selected', String(isActive))
    })
  }

  _onOutsideClick (event) {
    if (!this.element.contains(event.target)) {
      this._closeList()
    }
  }
}
