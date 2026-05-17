# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books index search', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  def rendered_titles
    doc = Nokogiri::HTML.parse(response.body)
    doc.css('.book-card__title').map { |node| node.text.strip }
  end

  describe 'GET /books' do
    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get books_path, params: { title: 'テスト' }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      let!(:title_hit) do
        create(:book, user: user, title: 'リーダブルコード', author: 'Dustin Boswell', genre: 'プログラミング',
                      status: :reading, deadline: Date.current + 2)
      end
      let!(:author_hit) do
        create(:book, user: user, title: '現場Rails', author: 'Yamada Taro', genre: 'プログラミング',
                      status: :unread, deadline: Date.current + 5)
      end
      let!(:completed_old) do
        create(:book, user: user, title: '読了済みA', author: 'Alice', genre: '自己啓発',
                      status: :completed, deadline: Date.current + 1,
                      completed_at: Time.zone.local(2026, 5, 1, 10, 0, 0))
      end
      let!(:completed_recent) do
        create(:book, user: user, title: '読了済みB', author: 'Bob', genre: 'ビジネス',
                      status: :completed, deadline: Date.current + 3,
                      completed_at: Time.zone.local(2026, 5, 10, 10, 0, 0))
      end
      let!(:other_users_book) do
        create(:book, user: other_user, title: '他人の本', author: 'Other', status: :reading)
      end

      it '書籍名で部分一致検索できる' do
        get books_path, params: { title: 'リーダブル' }

        expect(response).to have_http_status(:ok)
        expect(rendered_titles).to include(title_hit.title)
        expect(rendered_titles).not_to include(author_hit.title)
      end

      it '著者名で部分一致検索できる' do
        get books_path, params: { author: 'Yamada' }

        expect(response).to have_http_status(:ok)
        expect(rendered_titles).to include(author_hit.title)
        expect(rendered_titles).not_to include(title_hit.title)
      end

      it 'ジャンルで部分一致検索できる' do
        get books_path, params: { genre: '自己' }

        expect(response).to have_http_status(:ok)
        expect(rendered_titles).to include(completed_old.title)
        expect(rendered_titles).not_to include(completed_recent.title)
      end

      it '読了期間の開始日だけ指定して検索できる' do
        get books_path, params: { completed_from: '2026-05-05' }

        expect(rendered_titles).to include(completed_recent.title)
        expect(rendered_titles).not_to include(completed_old.title)
      end

      it '読了期間の終了日だけ指定して検索できる' do
        get books_path, params: { completed_to: '2026-05-05' }

        expect(rendered_titles).to include(completed_old.title)
        expect(rendered_titles).not_to include(completed_recent.title)
      end

      it '読了期間の開始日と終了日を指定して検索できる' do
        get books_path, params: { completed_from: '2026-05-01', completed_to: '2026-05-06' }

        expect(rendered_titles).to include(completed_old.title)
        expect(rendered_titles).not_to include(completed_recent.title)
      end

      it '複合条件で検索できる' do
        get books_path, params: {
          title: '読了済み',
          author: 'Bob',
          genre: 'ビジネス',
          completed_from: '2026-05-08',
          completed_to: '2026-05-12'
        }

        expect(rendered_titles).to include(completed_recent.title)
        expect(rendered_titles).not_to include(completed_old.title)
      end

      it '期間が逆転入力でも正規化して検索できる' do
        get books_path, params: { completed_from: '2026-05-12', completed_to: '2026-05-08' }

        expect(rendered_titles).to include(completed_recent.title)
        expect(rendered_titles).not_to include(completed_old.title)
      end

      it '不正な日付は無視される' do
        get books_path, params: { completed_from: 'invalid-date' }

        expect(rendered_titles).to include(title_hit.title)
        expect(rendered_titles).to include(author_hit.title)
        expect(rendered_titles).to include(completed_old.title)
        expect(rendered_titles).to include(completed_recent.title)
      end

      it '検索条件がフォームに保持される' do
        get books_path, params: {
          title: 'リーダブル',
          author: 'Dustin',
          genre: 'プログラ',
          completed_from: '2026-05-01',
          completed_to: '2026-05-15'
        }

        expect(response.body).to include('value="リーダブル"')
        expect(response.body).to include('value="Dustin"')
        expect(response.body).to include('value="プログラ"')
        expect(response.body).to include('value="2026-05-01"')
        expect(response.body).to include('value="2026-05-15"')
      end

      it '自分の書籍だけが検索対象になる' do
        get books_path, params: { title: 'リーダブル' }

        expect(rendered_titles).to include(title_hit.title)
        expect(rendered_titles).not_to include(other_users_book.title)
      end

      it '検索時も既存ソート（未了本優先・期限順）が維持される' do
        mixed_reading = create(:book, user: user, title: '共通検索_読書中', status: :reading, deadline: Date.current + 10)
        mixed_unread = create(:book, user: user, title: '共通検索_未読', status: :unread, deadline: Date.current + 2)
        mixed_completed = create(:book, user: user, title: '共通検索_読了', status: :completed,
                                 deadline: Date.current + 1, completed_at: Time.zone.local(2026, 5, 15, 10, 0, 0))

        get books_path, params: { title: '共通検索' }

        expect(rendered_titles).to eq([ mixed_unread.title, mixed_reading.title, mixed_completed.title ])
      end

      it '検索結果が0件の場合は検索向けの空メッセージを表示する' do
        get books_path, params: { title: '存在しないタイトル' }

        expect(response.body).to include('条件に一致する本がありません')
        expect(response.body).to include('検索条件をクリア')
      end
    end
  end
end
