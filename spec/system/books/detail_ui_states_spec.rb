# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '書籍詳細のUI状態', type: :system do
  let!(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  describe '期限警告表示' do
    it '残り7日でurgent-lowが表示される' do
      book = create(:book, user: user, title: 'low本', deadline: Date.current + 6)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover.book-card__cover--urgent-low')
      expect(page).to have_text('あと7日')
    end

    it '残り3日でurgent-mediumが表示される' do
      book = create(:book, user: user, title: 'medium本', deadline: Date.current + 2)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover.book-card__cover--urgent-medium')
      expect(page).to have_text('あと3日')
    end

    it '残り1日でurgent-highと期限間近バッジが表示される' do
      book = create(:book, user: user, title: 'high本', deadline: Date.current)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover.book-card__cover--urgent-high')
      expect(page).to have_text('期限間近！')
    end

    it '残り8日以上では警告クラスが表示されない' do
      book = create(:book, user: user, title: 'normal本', deadline: Date.current + 7)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover:not(.book-card__cover--urgent-low):not(.book-card__cover--urgent-medium):not(.book-card__cover--urgent-high)')
      expect(page).not_to have_css('.book-show__urgency-badge')
    end

    it '読了済みでは警告クラスが表示されない' do
      book = create(:book, user: user, title: 'done本', status: :completed, current_page: 100, pages: 100, deadline: Date.current)

      visit book_path(book)

      expect(page).to have_css('.book-show__cover:not(.book-card__cover--urgent-low):not(.book-card__cover--urgent-medium):not(.book-card__cover--urgent-high)')
      expect(page).not_to have_css('.book-show__urgency-badge')
    end
  end

  describe 'Googleカレンダー連携セクション' do
    it '連携セクションとデフォルト30分が表示される' do
      book = create(:book, user: user, title: 'カレンダーテスト本')

      visit book_path(book)

      expect(page).to have_text('Googleカレンダーで予定を作る')
      expect(page).to have_css('[data-controller="google-calendar"]')
      duration_radio = find('input[name="gcal_duration"][value="30"]', visible: :all)
      expect(duration_radio.checked?).to be(true)
      expect(page).to have_text('MVPでは、Google側での予定の変更・削除はアプリ内に反映されません')
    end
  end

  describe 'メモ機能の表示順と非同期追加' do
    let!(:book) { create(:book, user: user, title: 'テスト対象書籍') }

    it 'メモが作成日時の降順（最新が上）で初期表示されること' do
      create(:book_memo, book: book, content: '古いメモ', created_at: 10.minutes.ago)
      create(:book_memo, book: book, content: '新しいメモ', created_at: 1.minute.ago)

      visit book_path(book)

      items = all('.memo-timeline__item')
      expect(items[0]).to have_text('新しいメモ')
      expect(items[1]).to have_text('古いメモ')
    end

    it '新規メモを追加した際、非同期でリストの先頭に追加されること', js: true do
      create(:book_memo, book: book, content: '既存のメモ', created_at: 10.minutes.ago)

      visit book_path(book)
      expect(page).to have_text('既存のメモ')

      fill_in 'book_memo_content', with: '新規追加したメモ'
      click_button 'メモを追加する'

      # 非同期で追加されるのを待つ
      expect(page).to have_text('新規追加したメモ')

      items = all('.memo-timeline__item')
      expect(items[0]).to have_text('新規追加したメモ')
      expect(items[1]).to have_text('既存のメモ')
    end
  end

  describe '書影拡大モーダル', js: true do
    let!(:book) { create(:book, user: user, title: '書影テスト本', cover_image_url: 'http://example.com/cover.png') }

    before do
      allow_any_instance_of(BooksHelper).to receive(:book_cover_src).and_return('/icon.png')
    end

    it '書影画像をクリックしたときにモーダルが表示され、閉じるボタンまたは背景をクリックすると閉じること' do
      visit book_path(book)

      # 初期状態ではモーダルダイアログは表示されていない
      expect(page).to have_css('.image-modal-dialog', visible: false)
      expect(page).not_to have_css('dialog.image-modal-dialog[open]')

      # 書影画像をクリック
      find('.book-show__cover-image').click

      # モーダルが表示され、dialogにopen属性が付与されていることを確認
      expect(page).to have_css('dialog.image-modal-dialog[open]')
      expect(page).to have_css('.image-modal-dialog__image', visible: true)

      # 閉じるボタン（✕）をクリック
      find('.image-modal-dialog__close').click

      # モーダルが閉じ、open属性が消えることを確認
      expect(page).not_to have_css('dialog.image-modal-dialog[open]')

      # 再度書影をクリックして開き、背景クリックで閉じることを検証
      find('.book-show__cover-image').click
      expect(page).to have_css('dialog.image-modal-dialog[open]')

      # ダイアログの外側（背景）をクリック
      # HTML5 dialog の場合、dialog自体をクリックするとbackdropのクリックとして判定されるようにStimulusを実装している
      # Capybaraの標準clickだと要素の中心（画像）をクリックしてしまうため、JSでdialog要素自体に直接clickイベントを送信してbackdropクリックをシミュレートする
      page.execute_script("document.querySelector('dialog.image-modal-dialog').click()")
      expect(page).not_to have_css('dialog.image-modal-dialog[open]')
    end
  end
end
