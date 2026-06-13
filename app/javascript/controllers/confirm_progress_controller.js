import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input" ]
  static values = {
    lastPage: Number
  }

  check(event) {
    const currentVal = parseInt(this.inputTarget.value, 10)

    // 入力が数値でない場合はそのまま送信（Rails側のバリデーションに任せる）
    if (isNaN(currentVal)) {
      return
    }

    const lastVal = this.lastPageValue
    const diff = currentVal - lastVal

    let message = ""
    if (diff > 0) {
      message = `新しく ${diff} ページ読み進めましたか？（累計: ${currentVal} ページ）`
    } else if (diff < 0) {
      message = `現在のページ数を戻しますか？（累計: ${currentVal} ページ）`
    } else {
      message = `進捗を更新しますか？（累計: ${currentVal} ページ）`
    }

    if (!window.confirm(message)) {
      event.preventDefault()
    }
  }
}
