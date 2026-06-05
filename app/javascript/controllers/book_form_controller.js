import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['pages', 'deadline', 'quotaDisplay',
    'title', 'titleStatus', 'coverPreview', 'currentPage']

  connect () {
    this.calculateQuota()
    this.fetchingTitle = null
    this.fetchPromise = null
    this.cachedBook = null
    this.syncCompletedAtFieldVisibility()
  }

  syncCompletedAtFieldVisibility () {
    const checkbox = document.getElementById('book_is_past_reading')
    this._setCompletedAtFieldVisibility(checkbox ? checkbox.checked : false)
  }

  markTitleFetched (title) {
    this.fetchingTitle = title || ''
  }

  applyAutocompleteSelection (book) {
    this.markTitleFetched(book.title)
    this._updateCoverPreview(book.cover_image_url)
    this._setTitleStatus('書籍情報を自動入力しました')
  }

  async fetchByTitle () {
    const title = this.hasTitleTarget ? this.titleTarget.value.trim() : ''
    if (!title) {
      this._setTitleStatus('タイトルを入力してください。')
      return false
    }

    return this._fetchBookByTitle(title)
  }

  async _fetchBookByTitle (title, { fillForm = true } = {}) {
    if (this.fetchPromise && this.fetchingTitle === title) {
      await this.fetchPromise
      return true
    }

    this.fetchingTitle = title
    this.fetchPromise = this._performFetchByTitle(title, { fillForm })

    try {
      return await this.fetchPromise
    } finally {
      this.fetchPromise = null
    }
  }

  async _performFetchByTitle (title, { fillForm = true } = {}) {
    this._setTitleStatus('書影を取得中...')

    try {
      const res = await fetch(`/books/search?q=${encodeURIComponent(title)}`, {
        headers: { Accept: 'application/json' }
      })
      if (!res.ok) throw new Error('Network error')

      const data = await res.json()
      if (data.error) {
        this._setTitleStatus(data.error)
        return false
      }

      const books = data.books || []
      if (books.length === 0) {
        this._setTitleStatus('タイトルから書籍情報を取得できませんでした。')
        return false
      }

      const book = books[0]
      this.cachedBook = book

      if (fillForm) {
        const missing = this._fillFormFromSearch(book)
        const coverUrlInput = document.getElementById('book_cover_image_url')
        this._updateCoverPreview(coverUrlInput ? coverUrlInput.value : '')
        this._setTitleStatus(this._buildFetchResultMessage(missing))
      }

      return true
    } catch (_e) {
      this._setTitleStatus('取得中にエラーが発生しました。')
      return false
    } finally {
      this.markTitleFetched(title)
    }
  }

  _fillFormFromSearch ({ title, author, translator, publisher, genre, pages, total_pages: totalPages, cover_image_url: coverUrl, isbn }, { fillTitle = false } = {}) {
    const titleInput = this.hasTitleTarget ? this.titleTarget : null
    const authorInput = document.getElementById('book_author')
    const translatorInput = document.getElementById('book_translator')
    const publisherInput = document.getElementById('book_publisher')
    const genreInput = document.getElementById('book_genre')
    const pagesInput = document.getElementById('book_pages')
    const currentPageInput = document.getElementById('book_current_page')
    const coverUrlInput = document.getElementById('book_cover_image_url')
    const isbnInput = document.getElementById('book_isbn')
    const missing = []

    if (fillTitle && titleInput && title) {
      titleInput.value = title
    }

    if (authorInput && author) {
      if (!authorInput.value.trim()) {
        authorInput.value = author
      }
    } else {
      missing.push('著者')
    }

    if (translatorInput && translator) {
      if (!translatorInput.value.trim()) {
        translatorInput.value = translator
      }
    }

    if (publisherInput && publisher) {
      if (!publisherInput.value.trim()) {
        publisherInput.value = publisher
      }
    }

    if (genreInput && genre) {
      if (!genreInput.value.trim()) {
        genreInput.value = genre
      }
    }

    const finalPages = pages || totalPages
    if (pagesInput && finalPages) {
      if (!pagesInput.value.trim()) {
        pagesInput.value = finalPages
        pagesInput.dispatchEvent(new Event('input'))
      } else if (currentPageInput) {
        // 入力済みの pages/current を尊重しつつノルマ表示だけ再計算する。
        this.calculateQuota()
      }
    } else {
      missing.push('ページ数')
    }

    if (coverUrlInput && coverUrl) {
      if (!coverUrlInput.value.trim()) {
        coverUrlInput.value = coverUrl
      }
    } else {
      missing.push('書影')
    }

    if (isbnInput) {
      isbnInput.value = isbn || ''
    }

    return missing
  }

  _buildFetchResultMessage (missing) {
    if (missing.length === 0) {
      return 'タイトル・著者・ページ数・書影をすべて取得しました。'
    }
    return `書籍情報を取得しましたが、${missing.join('・')}は取得できませんでした。`
  }

  _updateCoverPreview (coverUrl) {
    if (!this.hasCoverPreviewTarget) return
    const container = this.coverPreviewTarget
    if (coverUrl) {
      const img = document.createElement('img')
      img.src = coverUrl
      img.alt = '書影プレビュー'
      img.className = 'book-cover-preview__image'
      container.replaceChildren(img)
      container.hidden = false
    } else {
      container.replaceChildren()
      container.hidden = true
    }
  }

  _setTitleStatus (message) {
    if (this.hasTitleStatusTarget) {
      this.titleStatusTarget.textContent = message
    }
  }

  calculateQuota () {
    const pages = parseInt(this.pagesTarget.value, 10)
    const currentPage = parseInt(this.currentPageTarget.value, 10)
    const deadlineValue = this.deadlineTarget.value
    const display = this.quotaDisplayTarget

    if (isNaN(pages) || pages <= 0 || !deadlineValue) {
      this._showPlaceholder(display)
      return
    }

    if (!isNaN(currentPage) && currentPage < 0) {
      this._showError(display, '既に読んだページ数は0以上を入力してください')
      return
    }

    if (!isNaN(currentPage) && currentPage > pages) {
      this._showError(display, '既に読んだページ数はページ数以下を入力してください')
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

    const normalizedCurrentPage = isNaN(currentPage) ? 0 : currentPage
    const remainingPages = Math.max(pages - normalizedCurrentPage, 0)
    const remainingDays = Math.floor((deadline - today) / (1000 * 60 * 60 * 24)) + 1
    const quota = Math.ceil(remainingPages / remainingDays)

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

  clearCoverImageUrl () {
    const coverUrlInput = document.getElementById('book_cover_image_url')
    if (coverUrlInput) {
      coverUrlInput.value = ''
    }
  }

  toggleCompletedAtField (event) {
    const field = document.getElementById('completed_at_field')
    if (!field) return

    if (event.target.checked) {
      this._setCompletedAtFieldVisibility(true)
    } else {
      this._setCompletedAtFieldVisibility(false)
      // チェックを外した場合は読了日フィールドをクリア
      const completedAtInput = document.getElementById('book_completed_at_input')
      if (completedAtInput) {
        completedAtInput.value = ''
      }
    }
  }

  _setCompletedAtFieldVisibility (visible) {
    const field = document.getElementById('completed_at_field')
    if (!field) return
    field.hidden = !visible
  }

  async fetchSingleField (event) {
    const field = event.currentTarget.dataset.field
    const title = this.hasTitleTarget ? this.titleTarget.value.trim() : ''
    if (!title) {
      this._setTitleStatus('タイトルを入力してください。')
      return
    }

    let book = this.cachedBook
    if (!book || this.fetchingTitle !== title) {
      const success = await this._fetchBookByTitle(title, { fillForm: false })
      if (!success) return
      book = this.cachedBook
    }

    if (!book) {
      this._setTitleStatus('書籍情報を取得できませんでした。')
      return
    }

    this._fillSingleField(field, book)
  }

  _fillSingleField (field, book) {
    let value = null
    let input = null
    let fieldNameJapanese = ''

    switch (field) {
      case 'author':
        value = book.author
        input = document.getElementById('book_author')
        fieldNameJapanese = '著者'
        break
      case 'translator':
        value = book.translator
        input = document.getElementById('book_translator')
        fieldNameJapanese = '翻訳者'
        break
      case 'publisher':
        value = book.publisher
        input = document.getElementById('book_publisher')
        fieldNameJapanese = '出版社'
        break
      case 'genre':
        value = book.genre
        input = document.getElementById('book_genre')
        fieldNameJapanese = 'ジャンル'
        break
      case 'pages':
        value = book.pages || book.total_pages
        input = document.getElementById('book_pages')
        fieldNameJapanese = 'ページ数'
        break
      case 'cover':
        value = book.cover_image_url
        input = document.getElementById('book_cover_image_url')
        fieldNameJapanese = '書影'
        break
    }

    if (input) {
      if (value) {
        input.value = value
        if (field === 'pages') {
          input.dispatchEvent(new Event('input'))
        }
        if (field === 'cover') {
          this._updateCoverPreview(value)
          const fileInput = document.getElementById('book_cover_image')
          if (fileInput) fileInput.value = ''
        }
        this._setTitleStatus(`${fieldNameJapanese}を取得しました。`)
      } else {
        this._setTitleStatus(`${fieldNameJapanese}の情報は見つかりませんでした。`)
      }
    }
  }
}
