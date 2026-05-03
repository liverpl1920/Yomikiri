import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['totalPages', 'targetPages', 'deadline', 'quotaDisplay',
    'title', 'titleStatus', 'isbnSection', 'isbn', 'isbnStatus']

  connect () {
    this.calculateQuota()
  }

  async autoFetchByTitle () {
    const title = this.hasTitleTarget ? this.titleTarget.value.trim() : ''
    if (!title) return

    this._setTitleStatus('書影を取得中...')

    try {
      const res = await fetch(`/books/search?q=${encodeURIComponent(title)}`, {
        headers: { Accept: 'application/json' }
      })
      if (!res.ok) throw new Error('Network error')

      const data = await res.json()
      if (data.error) {
        this._showIsbnFallback(data.error)
        return
      }

      const books = data.books || []
      if (books.length === 0) {
        this._showIsbnFallback('タイトルから書影・ISBNを取得できませんでした。ISBNが分かる場合は下記に入力してください。')
        return
      }

      const book = books[0]
      if (!book.cover_image_url) {
        this._fillFormFromSearch(book)
        this._showIsbnFallback('書影を取得できませんでした。ISBNが分かる場合は下記に入力してください。')
        return
      }

      this._fillFormFromSearch(book)
      this._setTitleStatus('書影と書籍情報を自動入力しました。')
      this._hideIsbnSection()
    } catch (_e) {
      this._showIsbnFallback('取得中にエラーが発生しました。ISBNが分かる場合は下記に入力してください。')
    }
  }

  async fetchByIsbn () {
    const isbn = this.hasIsbnTarget ? this.isbnTarget.value.trim() : ''
    if (!isbn) return

    this._setIsbnStatus('取得中...')

    try {
      const res = await fetch(`/books/search?q=${encodeURIComponent(isbn)}`, {
        headers: { Accept: 'application/json' }
      })
      if (!res.ok) throw new Error('Network error')

      const data = await res.json()
      const books = data.books || []

      if (books.length === 0 || !books[0].cover_image_url) {
        this._setIsbnStatus('書影を取得できませんでした。')
        return
      }

      const coverUrlInput = document.getElementById('book_cover_image_url')
      if (coverUrlInput) coverUrlInput.value = books[0].cover_image_url
      this._setIsbnStatus('書影を取得しました。')
    } catch (_e) {
      this._setIsbnStatus('取得中にエラーが発生しました。')
    }
  }

  _showIsbnFallback (message) {
    this._setTitleStatus(message)
    if (this.hasIsbnSectionTarget) {
      this.isbnSectionTarget.classList.remove('book-form__isbn-section--hidden')
    }
  }

  _hideIsbnSection () {
    if (this.hasIsbnSectionTarget) {
      this.isbnSectionTarget.classList.add('book-form__isbn-section--hidden')
    }
  }

  _fillFormFromSearch ({ author, total_pages: totalPages, cover_image_url: coverUrl }) {
    const authorInput = document.getElementById('book_author')
    const totalPagesInput = document.getElementById('book_total_pages')
    const coverUrlInput = document.getElementById('book_cover_image_url')

    if (authorInput && author) authorInput.value = author
    if (coverUrlInput) coverUrlInput.value = coverUrl || ''

    if (totalPagesInput && totalPages) {
      totalPagesInput.value = totalPages
      totalPagesInput.dispatchEvent(new Event('input'))
    }
  }

  _setTitleStatus (message) {
    if (this.hasTitleStatusTarget) {
      this.titleStatusTarget.textContent = message
    }
  }

  _setIsbnStatus (message) {
    if (this.hasIsbnStatusTarget) {
      this.isbnStatusTarget.textContent = message
    }
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
