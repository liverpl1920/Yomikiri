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
      expect(page).to have_text('50 冊')
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

    it '日別読書ログに日付・本・ページ数が表示される' do
      book = create(:book, user: user, title: 'ログ表示本')
      create(:reading_log, book: book, read_at: Date.current, pages_read: 12)
      login_as(user, scope: :user)

      visit mypage_path

      expect(page).to have_text('日別読書ログ')
      expect(page).to have_text(I18n.l(Date.current, format: :long))
      expect(page).to have_text('ログ表示本')
      expect(page).to have_text('+12ページ')
    end

    it '読書ログがない日も記録なしとして表示される' do
      book = create(:book, user: user, title: 'ログ表示本')
      create(:reading_log, book: book, read_at: Date.current, pages_read: 12)
      login_as(user, scope: :user)

      visit mypage_path

      expect(page).to have_text(I18n.l(Date.current - 1.day, format: :long))
      expect(page).to have_text('記録なし')
    end

    it '連続読書日数（ストリーク）が表示され、0日の時は「0日」、1日以上の時は「X日連続」と表示されること' do
      login_as(user, scope: :user)

      visit mypage_path
      within '.mypage__stats' do
        expect(page).to have_text("0")
        expect(page).to have_text("日")
        expect(page).not_to have_text("日連続")
      end

      # 今日の読書ログを作成してストリークを1にする
      book = create(:book, user: user, title: 'テスト本')
      create(:reading_log, book: book, read_at: Date.current, pages_read: 10)

      visit mypage_path
      within '.mypage__stats' do
        expect(page).to have_text("1")
        expect(page).to have_text("日連続")
      end
    end
  end

  describe 'プロフィール更新' do
    before do
      login_as(user, scope: :user)
      visit mypage_path
    end

    it '有効な値でニックネームと年間目標を更新できる' do
      fill_in 'ニックネーム（最大50文字）', with: '更新後ニックネーム'
      fill_in '年間目標（目標冊数）', with: '30'
      click_button '更新する'

      expect(page).to have_current_path(mypage_path)
      expect(page).to have_text('プロフィールを更新しました。')
      expect(user.reload.nickname).to eq('更新後ニックネーム')
      expect(user.reload.yearly_goal).to eq(30)
    end

    it 'ニックネーム入力欄はmaxlength=50が効いている' do
      fill_in 'ニックネーム（最大50文字）', with: 'a' * 51

      # maxlength=50 が効いていることを確認する
      expect(find('input[name="user[nickname]"]', visible: :all).value.length).to eq(50)
    end

    it '無効な年間目標（0）は更新できずエラーが表示される' do
      fill_in '年間目標（目標冊数）', with: '0'
      click_button '更新する'

      expect(page).to have_text('年間目標')
      expect(page).to have_text('1以上')
    end

    it '更新に失敗した場合でも、登録済みのジャンルが表示されたままであること' do
      create(:genre, user: user, name: '既存ジャンル')
      visit mypage_path

      expect(page).to have_text('既存ジャンル')

      fill_in '年間目標（目標冊数）', with: '0'
      click_button '更新する'

      expect(page).to have_text('既存ジャンル')
      expect(page).not_to have_text('ジャンルはまだ登録されていません。')
    end
  end

  describe '読書統計' do
    let(:book_technical) { create(:book, user: user, title: 'Go言語', category: :technical) }
    let(:book_literature) { create(:book, user: user, title: '人間失格', category: :literature) }

    before do
      create(:reading_log, book: book_technical, read_at: Date.current, pages_read: 80)
      create(:reading_log, book: book_literature, read_at: Date.current, pages_read: 20)
      login_as(user, scope: :user)
    end

    it '統計ページにアクセスすると、種類別読書ポートフォリオが表示される' do
      visit stats_mypage_path

      expect(page).to have_text('種類別読書ポートフォリオ')
      expect(page).to have_text('技術書')
      expect(page).to have_text('80 ページ (80.0%)')
      expect(page).to have_text('純文学')
      expect(page).to have_text('20 ページ (20.0%)')
    end
  end

  describe 'ジャンル設定', js: true do
    before do
      login_as(user, scope: :user)
    end

    it '登録済みのジャンルが表示される' do
      genre = create(:genre, user: user, name: '既存ジャンル')
      visit mypage_path

      expect(page).to have_text('既存ジャンル')
      expect(page).not_to have_text('ジャンルはまだ登録されていません。')
    end

    it 'ジャンルが登録されていない場合はメッセージが表示される' do
      user.genres.destroy_all
      visit mypage_path

      expect(page).to have_text('ジャンルはまだ登録されていません。')
    end

    it 'ジャンルを新規登録できる' do
      visit mypage_path

      fill_in 'genre_name_input', with: '新規ジャンル'
      click_button '追加'

      expect(page).to have_text('新規ジャンル')
      expect(page).not_to have_text('ジャンルはまだ登録されていません。')
    end

    it 'ジャンルを編集できる' do
      genre = create(:genre, user: user, name: '編集前ジャンル')
      visit mypage_path

      within "#genre_#{genre.id}" do
        click_link '編集'
        fill_in 'genre[name]', with: '編集後ジャンル'
        click_button '保存'
      end

      expect(page).to have_text('編集後ジャンル')
      expect(page).not_to have_text('編集前ジャンル')
    end

    it 'ジャンルを削除できる' do
      user.genres.destroy_all
      genre = create(:genre, user: user, name: '削除対象ジャンル')
      visit mypage_path

      expect(page).to have_text('削除対象ジャンル')

      # JS confirm のハンドリング
      page.accept_confirm '「削除対象ジャンル」を削除しますか？' do
        within "#genre_#{genre.id}" do
          click_button '削除'
        end
      end

      expect(page).not_to have_text('削除対象ジャンル')
      expect(page).to have_text('ジャンルはまだ登録されていません。')
    end
  end
end
