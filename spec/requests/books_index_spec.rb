# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books index search', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  def rendered_titles
    doc = Nokogiri::HTML.parse(response.body)
    doc.css('.book-card__title').map { |node| node.text.strip }
  end

  def rendered_memo_contents
    doc = Nokogiri::HTML.parse(response.body)
    doc.css('.memo-timeline__body').map { |node| node.text.strip }
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

      it '書籍の種類で絞り込み検索できる' do
        technical_book = create(:book, user: user, title: '技術書A', category: :technical)
        literature_book = create(:book, user: user, title: '純文学B', category: :literature)

        get books_path, params: { category: 'technical' }

        expect(response).to have_http_status(:ok)
        expect(rendered_titles).to include(technical_book.title)
        expect(rendered_titles).not_to include(literature_book.title)
      end

      it '書籍の種類が未指定（空）の場合は絞り込まない' do
        technical_book = create(:book, user: user, title: '技術書A', category: :technical)
        literature_book = create(:book, user: user, title: '純文学B', category: :literature)

        get books_path, params: { category: '' }

        expect(response).to have_http_status(:ok)
        expect(rendered_titles).to include(technical_book.title)
        expect(rendered_titles).to include(literature_book.title)
      end

      it '書籍の種類の検索条件がフォームに保持される' do
        get books_path, params: { category: 'technical' }

        doc = Nokogiri::HTML.parse(response.body)
        selected_option = doc.css('select#category option[selected]')
        expect(selected_option.text).to eq('技術書')
        expect(selected_option.attr('value').value).to eq('technical')
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

        expect(response.body).to include('条件に一致する本やメモがありません')
        expect(response.body).to include('検索条件をクリア')
      end

      it 'メモがある本も一覧に表示されるがメモ欄は表示されない' do
        memo_book = create(:book, user: user, title: 'メモ付き本', memo: "この本は重要ポイントが多い。\n次回は3章から読む")

        get books_path

        doc = Nokogiri::HTML.parse(response.body)
        expect(response.body).to include(memo_book.title)
        expect(doc.css('.book-card__memo')).to be_empty
      end
    end
  end

  describe 'GET /books?memo_keyword=xxx （メモ直接検索）' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:book) { create(:book, user: user, title: 'テスト書籍', status: :reading, deadline: Date.current + 5) }
    let(:other_book) { create(:book, user: other_user, title: '他ユーザーの本', status: :reading) }
    let(:no_memo_book) { create(:book, user: user, title: 'メモなし書籍', status: :unread, deadline: Date.current + 10) }

    context '未ログインの場合' do
      it 'ログイン画面へリダイレクトされる' do
        get books_path, params: { memo_keyword: 'テスト' }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before { sign_in user }

      let!(:matching_memo) { create(:book_memo, book: book, content: 'ここが重要なポイントです') }
      let!(:other_memo) { create(:book_memo, book: book, content: '別の内容 of メモ') }
      let!(:other_user_memo) { create(:book_memo, book: other_book, content: '重要な他ユーザーメモ') }

      it '200を返す' do
        get books_path, params: { memo_keyword: '重要' }

        expect(response).to have_http_status(:ok)
      end

      it 'キーワードに一致するメモの内容が直接表示される' do
        get books_path, params: { memo_keyword: '重要' }

        expect(rendered_memo_contents).to include('ここが重要なポイントです')
        expect(rendered_memo_contents).not_to include('別の内容 of メモ')
      end

      it '他ユーザーのメモは表示されない' do
        get books_path, params: { memo_keyword: '重要' }

        expect(rendered_memo_contents).not_to include('重要な他ユーザーメモ')
      end

      it '本の検索条件が指定されていない場合、本の一覧は表示されない' do
        get books_path, params: { memo_keyword: '重要' }

        expect(rendered_titles).to be_empty
      end

      it '検索結果0件の場合は条件に一致する本やメモがないメッセージを表示する' do
        get books_path, params: { memo_keyword: '存在しないキーワード' }

        expect(response.body).to include('条件に一致する本やメモがありません')
      end

      it 'memo_keywordがない場合は本の一覧を表示する' do
        no_memo_book

        get books_path

        doc = Nokogiri::HTML.parse(response.body)
        expect(doc.css('.book-card__title')).not_to be_empty
        expect(response.body).not_to include('条件に一致する本やメモがありません')
      end

      it '検索キーワードがフォームに保持される' do
        get books_path, params: { memo_keyword: '重要' }

        expect(response.body).to include('value="重要"')
      end

      it 'memo_keywordとtitleを同時に指定して本とメモの両方を絞り込める' do
        another_book = create(:book, user: user, title: '別の書籍', status: :unread, deadline: Date.current + 7)
        create(:book_memo, book: another_book, content: '重要なメモ')

        get books_path, params: { memo_keyword: '重要', title: 'テスト' }

        expect(rendered_titles).to include(book.title)
        expect(rendered_titles).not_to include(another_book.title)
        expect(rendered_memo_contents).to include('ここが重要なポイントです')
        expect(rendered_memo_contents).not_to include('重要なメモ')
      end
    end
  end
end
