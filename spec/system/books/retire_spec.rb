# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '書籍リタイア機能', type: :system, js: true do
  let!(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  describe '詳細画面からのリタイア操作' do
    let!(:book) { create(:book, user: user, title: 'リタイアテスト本', pages: 100, current_page: 10, deadline: Date.current + 7, status: :reading) }

    it 'リタイアを実行するとステータスが更新され、詳細画面にリタイア理由が表示される' do
      visit book_path(book)

      # 1. 初期状態確認
      expect(page).to have_button('リタイアする')
      expect(page).to have_button('期限を延長する')
      expect(page).to have_button('読了にする！')
      expect(page).not_to have_text('リタイア理由')

      # 2. リタイアモーダルを開く
      click_button 'リタイアする'
      expect(page).to have_text('読書のリタイア')

      # 3. 理由を入力してリタイアを確定
      within('.modal') do
        fill_in 'retire_reason', with: '時間がなくなってしまったため'
        click_button 'リタイアする' # モーダル内の送信ボタン
      end

      # 4. 完了後の状態確認
      expect(page).to have_text('リタイアテスト本をリタイアしました。')
      expect(page).to have_text('リタイア理由')
      expect(page).to have_text('時間がなくなってしまったため')
      expect(page).to have_text('リタイア')

      # ボタン類の非表示確認
      expect(page).not_to have_button('リタイアする')
      expect(page).not_to have_button('期限を延長する')
      expect(page).not_to have_button('読了にする！')

      # DBのステータスと理由の更新確認
      expect(book.reload.status).to eq('retired')
      expect(book.retire_reason).to eq('時間がなくなってしまったため')
    end

    it '理由を入力せずにリタイアを実行できる' do
      visit book_path(book)

      click_button 'リタイアする'

      within('.modal') do
        click_button 'リタイアする' # モーダル内の送信ボタン（理由は空欄のまま）
      end

      expect(page).to have_text('リタイアテスト本をリタイアしました。')
      expect(page).to have_text('リタイア理由')
      expect(page).to have_text('なし') # view側で「なし」と表示するようにしている

      expect(book.reload.status).to eq('retired')
      expect(book.retire_reason).to be_blank
    end
  end

  describe '一覧画面での表示' do
    let!(:book_unread) { create(:book, user: user, title: '未読本', pages: 100, current_page: 0, deadline: Date.current + 10, status: :unread) }
    let!(:book_retired) { create(:book, user: user, title: 'リタイア本', pages: 100, current_page: 20, status: :retired, retire_reason: '難しすぎた') }

    it 'リタイア本はグレーアウトされ、ノルマが表示されず、下部にソートされる' do
      visit books_path

      # 1. スタイリング（グレーアウトクラス）の適用確認
      expect(page).to have_css('.book-card--retired')

      # 2. 今日のノルマが非表示であることの確認
      # 未読本にはノルマが表示されるが、リタイア本には表示されない
      expect(page).to have_text('未読本')
      expect(page).to have_text('リタイア本')

      # カード要素のテキストをチェック
      within(find('.book-card--retired')) do
        expect(page).not_to have_text('今日のノルマ')
        expect(page).to have_text('リタイア')
      end

      # 3. ソート順（未了本 -> リタイア本）の確認
      # 一覧の中で未読本がリタイア本より前に表示されていること
      titles = page.all('.book-card__title').map(&:text)
      expect(titles.index('未読本')).to be < titles.index('リタイア本')
    end
  end
end
