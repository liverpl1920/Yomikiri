import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['totalPages', 'targetPages', 'deadline', 'quotaDisplay',
    'title', 'titleStatus', 'coverPreview', 'currentPage']

  connect () {
    this.calculateQuota()
    this.fetchingTitle = null
    this.fetchPromise = null
    this.lastAutoFetchedTitle = ''
    this.syncCompletedAtFieldVisibility()
  }

  syncCompletedAtFieldVisibility () {
    const checkbox = document.getElementById('book_is_past_reading')
    this._setCompletedAtFieldVisibility(checkbox ? checkbox.checked : false)
  }

  markTitleFetched (title) {
    this.lastAutoFetchedTitle = title || ''
  }

  applyAutocompleteSelection (book) {
    this.markTitleFetched(book.title)
    this._updateCoverPreview(book.cover_image_url)
    this._setTitleStatus('書籍情報を自動入力しました')
  }

  async autoFetchByTitle () {
    const title = this.hasTitleTarget ? this.titleTarget.value.trim() : ''
    if (!title) return false

    return this._fetchBookByTitle(title)
  }

  async submitWithAutoFetch (event) {
    const title = this.hasTitleTarget ? this.titleTarget.value.trim() : ''
    if (!title) return

    const coverUrlInput = document.getElementById('book_cover_image_url')
    const hasCoverImage = coverUrlInput && coverUrlInput.value.trim() !== ''
    if (hasCoverImage || this.lastAutoFetchedTitle === title) return

    event.preventDefault()
    try {
      await this._fetchBookByTitle(title)
    } finally {
      setTimeout(() => this.element.submit(), 0)
    }
  }

  async _fetchBookByTitle (title) {
    if (this.fetchPromise && this.fetchingTitle === title) {
      await this.fetchPromise
      return true
    }

    this.fetchingTitle = title
    this.fetchPromise = this._performFetchByTitle(title)

    try {
      return await this.fetchPromise
    } finally {
      this.fetchPromise = null
    }
  }

  async _performFetchByTitle (title) {
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
        this._setTitleStatus('タイトルから書籍情報を取得できませんでした。ISBNで検索してみてください。')
        return false
      }

      const book = books[0]
      const missing = this._fillFormFromSearch(book)
      this._updateCoverPreview(book.cover_image_url)
      this._setTitleStatus(this._buildFetchResultMessage(missing))
      return true
    } catch (_e) {
      this._setTitleStatus('取得中にエラーが発生しました。')
      return false
    } finally {
      this.markTitleFetched(title)
    }
  }

  _fillFormFromSearch ({ author, total_pages: totalPages, cover_image_url: coverUrl }) {
    const authorInput = document.getElementById('book_author')
    const totalPagesInput = document.getElementById('book_total_pages')
    const coverUrlInput = document.getElementById('book_cover_image_url')
    const missing = []

    if (authorInput && author) {
      authorInput.value = author
    } else {
      missing.push('著者')
    }

    if (totalPagesInput && totalPages) {
      totalPagesInput.value = totalPages
      totalPagesInput.dispatchEvent(new Event('input'))
    } else {
      missing.push('ページ数')
    }

    if (coverUrlInput && coverUrl) {
      coverUrlInput.value = coverUrl
    } else {
      missing.push('書影')
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
    const currentPage = this.hasCurrentPageTarget
      ? parseInt(this.currentPageTarget.value, 10)
      : 0
    const deadlineValue = this.deadlineTarget.value
    const display = this.quotaDisplayTarget

    if (isNaN(targetPages) || targetPages <= 0 || !deadlineValue) {
      this._showPlaceholder(display)
      return
    }

    if (!isNaN(currentPage) && currentPage < 0) {
      this._showError(display, '既に読んだページ数は0以上を入力してください')
      return
    }

    if (!isNaN(currentPage) && currentPage > targetPages) {
      this._showError(display, '既に読んだページ数は読了対象ページ数以下を入力してください')
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
    const remainingPages = Math.max(targetPages - normalizedCurrentPage, 0)
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
}
