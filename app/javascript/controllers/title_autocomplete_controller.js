import { Controller } from '@hotwired/stimulus'

const DEBOUNCE_DELAY = 300
const MIN_QUERY_LENGTH = 2

export default class extends Controller {
  static targets = ['input', 'list']

  connect () {
    this._debounceTimer = null
    this._activeIndex = -1
    this._candidates = []
    this._handleOutsideClick = this._onOutsideClick.bind(this)
    document.addEventListener('click', this._handleOutsideClick)
  }

  disconnect () {
    clearTimeout(this._debounceTimer)
    document.removeEventListener('click', this._handleOutsideClick)
  }

  onInput () {
    clearTimeout(this._debounceTimer)
    const query = this.inputTarget.value.trim()

    if (query.length < MIN_QUERY_LENGTH) {
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
    try {
      const res = await fetch(`/books/search?q=${encodeURIComponent(query)}`, {
        headers: { Accept: 'application/json' }
      })
      if (!res.ok) throw new Error('Network error')

      const data = await res.json()
      if (data.error) {
        this._closeList()
        return
      }

      this._candidates = data.books || []
      this._renderList(this._candidates)
    } catch (_e) {
      this._closeList()
    }
  }

  _renderList (books) {
    const list = this.listTarget
    list.innerHTML = ''
    this._activeIndex = -1

    if (books.length === 0) {
      this._closeList()
      return
    }

    books.forEach((book, index) => {
      const li = document.createElement('li')
      li.className = 'title-autocomplete__item'
      li.setAttribute('role', 'option')
      li.setAttribute('aria-selected', 'false')
      li.dataset.index = index

      const button = document.createElement('button')
      button.type = 'button'
      button.className = 'title-autocomplete__button'

      if (book.cover_image_url) {
        const img = document.createElement('img')
        img.src = book.cover_image_url
        img.alt = ''
        img.className = 'title-autocomplete__cover'
        button.appendChild(img)
      }

      const info = document.createElement('span')
      info.className = 'title-autocomplete__info'

      const title = document.createElement('span')
      title.className = 'title-autocomplete__title'
      title.textContent = book.title || ''
      info.appendChild(title)

      if (book.author) {
        const author = document.createElement('span')
        author.className = 'title-autocomplete__author'
        author.textContent = book.author
        info.appendChild(author)
      }

      button.appendChild(info)
      button.addEventListener('click', () => this._selectCandidate(book))
      li.appendChild(button)
      list.appendChild(li)
    })

    list.classList.remove('title-autocomplete__list--hidden')
    list.setAttribute('aria-expanded', 'true')
  }

  _selectCandidate (book) {
    this._fillForm(book)
    this._closeList()

    // blur時のautoFetchを抑止するためbook-formコントローラのlastAutoFetchedTitleを更新
    const formController = this._getBookFormController()
    if (formController) {
      formController.lastAutoFetchedTitle = book.title || ''
      formController._updateCoverPreview(book.cover_image_url)
      formController._setTitleStatus('書籍情報を自動入力しました')
    }
  }

  _fillForm (book) {
    const titleInput = document.getElementById('book_title')
    const authorInput = document.getElementById('book_author')
    const totalPagesInput = document.getElementById('book_total_pages')
    const coverUrlInput = document.getElementById('book_cover_image_url')

    if (titleInput) titleInput.value = book.title || ''
    if (authorInput) authorInput.value = book.author || ''
    if (coverUrlInput) coverUrlInput.value = book.cover_image_url || ''

    if (totalPagesInput) {
      totalPagesInput.value = book.total_pages ?? ''
      totalPagesInput.dispatchEvent(new Event('input'))
    }
  }

  _moveFocus (direction) {
    const items = this.listTarget.querySelectorAll('.title-autocomplete__item')
    if (items.length === 0) return

    const prevIndex = this._activeIndex
    this._activeIndex = Math.max(-1, Math.min(items.length - 1, this._activeIndex + direction))

    if (prevIndex >= 0 && items[prevIndex]) {
      items[prevIndex].classList.remove('title-autocomplete__item--active')
      items[prevIndex].setAttribute('aria-selected', 'false')
    }

    if (this._activeIndex >= 0 && items[this._activeIndex]) {
      items[this._activeIndex].classList.add('title-autocomplete__item--active')
      items[this._activeIndex].setAttribute('aria-selected', 'true')
      items[this._activeIndex].scrollIntoView({ block: 'nearest' })
    }
  }

  _closeList () {
    const list = this.listTarget
    list.innerHTML = ''
    list.classList.add('title-autocomplete__list--hidden')
    list.setAttribute('aria-expanded', 'false')
    this._activeIndex = -1
    this._candidates = []
  }

  _isListOpen () {
    return !this.listTarget.classList.contains('title-autocomplete__list--hidden')
  }

  _onOutsideClick (event) {
    if (!this.element.contains(event.target)) {
      this._closeList()
    }
  }

  _getBookFormController () {
    const formElement = this.element.closest('form[data-controller]') ||
      document.querySelector('form[data-controller~="book-form"]')
    if (!formElement) return null
    const app = this.application
    return app.getControllerForElementAndIdentifier(formElement, 'book-form')
  }
}
