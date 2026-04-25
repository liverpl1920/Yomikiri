# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'マイページ', type: :system do
  let!(:user) { create(:user, nickname: '初期ニックネーム') }

  describe '表示' do
    it '未ログイン時はログイン画面へ遷移する' do
      visit mypage_path

      expect(page).to have_current_path(new_user_session_path)
    end

    it 'ログイン済みユーザーのプロフィール情報が表示される' do
      login_as(user, scope: :user)

      visit mypage_path

      expect(page).to have_text('マイページ')
      expect(page).to have_text(user.email)
      expect(page).to have_text('初期ニックネーム')
    end

    it '読了履歴がない場合は空メッセージが表示される' do
      login_as(user, scope: :user)

      visit mypage_path

      expect(page).to have_text('読了した本はまだありません。')
    end

    it '読了履歴がある場合は対象書籍が表示される' do
      completed_book = create(:book, user: user, status: :completed, completed_at: 1.day.ago, title: '読了履歴本')
      login_as(user, scope: :user)

      visit mypage_path

      expect(page).to have_link(completed_book.title, href: book_path(completed_book))
    end
  end

  describe 'ニックネーム更新' do
    before do
      login_as(user, scope: :user)
      visit mypage_path
    end

    it '有効な値で更新できる' do
      fill_in 'ニックネーム（最大50文字）', with: '更新後ニックネーム'
      click_button '更新する'

      expect(page).to have_current_path(mypage_path)
      expect(page).to have_text('ニックネームを更新しました。')
      expect(user.reload.nickname).to eq('更新後ニックネーム')
    end

    it '51文字以上はエラーになる' do
      fill_in 'ニックネーム（最大50文字）', with: 'a' * 51

      # maxlength=50 が効いていることを確認する
      expect(find('input[name="user[nickname]"]', visible: :all).value.length).to eq(50)
    end
  end
end
