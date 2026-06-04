import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['query', 'status', 'results']

  connect () {
    this.resultsTarget.classList.add('book-search__results--hidden')
    this.statusTarget.textContent = ''
  }

  async search () {
    const query = this.queryTarget.value.trim()
    if (!query) return

    this._setStatus('検索中...')
    this.resultsTarget.innerHTML = ''
    this.resultsTarget.classList.add('book-search__results--hidden')

    try {
      const res = await fetch(`/books/search?q=${encodeURIComponent(query)}`, {
        headers: { Accept: 'application/json' }
      })
      if (!res.ok) throw new Error('Network error')

      const data = await res.json()
      if (data.error) {
        this._setStatus(data.error)
        return
      }
      this._handleResults(data.books || [])
    } catch (_e) {
      this._setStatus('検索中にエラーが発生しました')
    }
  }

  handleKeydown (event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      this.search()
    }
  }

  _handleResults (books) {
    if (books.length === 0) {
      this._setStatus('該当する書籍が見つかりませんでした')
      return
    }

    if (books.length === 1) {
      this._fillForm(books[0])
      this._setStatus('書籍情報を自動入力しました')
      return
    }

    this._showCandidates(books)
    this._setStatus(`${books.length}件の候補が見つかりました。選択してください。`)
  }

  _showCandidates (books) {
    const ul = this.resultsTarget
    ul.innerHTML = ''

    books.forEach((book) => {
      const li = document.createElement('li')
      li.className = 'book-search__result-item'
      const button = document.createElement('button')
      button.type = 'button'
      button.className = 'book-search__result-button'
      button.textContent = `${book.title}${book.author ? ' / ' + book.author : ''}`
      button.addEventListener('click', () => {
        this._fillForm(book)
        ul.innerHTML = ''
        ul.classList.add('book-search__results--hidden')
        this._setStatus('書籍情報を自動入力しました')
      })
      li.appendChild(button)
      ul.appendChild(li)
    })

    ul.classList.remove('book-search__results--hidden')
  }

  _fillForm ({ title, author, translator, publisher, pages, total_pages: totalPages, cover_image_url: coverUrl, isbn }) {
    const titleInput = document.getElementById('book_title')
    const authorInput = document.getElementById('book_author')
    const translatorInput = document.getElementById('book_translator')
    const publisherInput = document.getElementById('book_publisher')
    const pagesInput = document.getElementById('book_pages')
    const coverUrlInput = document.getElementById('book_cover_image_url')
    const isbnInput = document.getElementById('book_isbn')

    if (titleInput) titleInput.value = title || ''
    if (authorInput) authorInput.value = author || ''
    if (translatorInput) translatorInput.value = translator || ''
    if (publisherInput) publisherInput.value = publisher || ''
    if (coverUrlInput) coverUrlInput.value = coverUrl || ''
    if (isbnInput) isbnInput.value = isbn || ''

    const finalPages = pages || totalPages
    if (pagesInput) {
      pagesInput.value = finalPages ?? ''
      pagesInput.dispatchEvent(new Event('input'))
    }
  }

  _setStatus (message) {
    this.statusTarget.textContent = message
  }
}
