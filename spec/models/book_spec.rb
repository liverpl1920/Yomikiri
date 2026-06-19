require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'ファクトリ' do
    it '有効なファクトリを持つ' do
      expect(build(:book)).to be_valid
    end
  end

  describe 'バリデーション' do
    describe 'title' do
      it 'タイトルがない場合は無効' do
        expect(build(:book, title: '')).not_to be_valid
      end

      it 'タイトルが255文字以内であれば有効' do
        expect(build(:book, title: 'a' * 255)).to be_valid
      end

      it 'タイトルが256文字以上の場合は無効' do
        expect(build(:book, title: 'a' * 256)).not_to be_valid
      end
    end

    describe 'pages' do
      it 'ページ数がない場合は無効' do
        expect(build(:book, pages: nil)).not_to be_valid
      end

      it 'ページ数が0の場合は無効' do
        expect(build(:book, pages: 0)).not_to be_valid
      end

      it 'ページ数が1以上であれば有効' do
        expect(build(:book, pages: 1)).to be_valid
      end

      it 'ページ数が小数の場合は無効' do
        expect(build(:book, pages: 1.5)).not_to be_valid
      end
    end

    describe 'current_page' do
      it '現在ページがない場合は無効' do
        expect(build(:book, current_page: nil)).not_to be_valid
      end

      it '現在ページが0であれば有効' do
        expect(build(:book, current_page: 0)).to be_valid
      end

      it '現在ページがページ数以下であれば有効' do
        expect(build(:book, pages: 300, current_page: 300)).to be_valid
      end

      it '現在ページがページ数を超える場合は無効' do
        expect(build(:book, pages: 300, current_page: 301)).not_to be_valid
      end

      it '現在ページが負の値の場合は無効' do
        expect(build(:book, current_page: -1)).not_to be_valid
      end
    end

    describe 'deadline' do
      it '積読書籍（unread）は読了期限なしで有効' do
        expect(build(:book, deadline: nil, status: :unread)).to be_valid
      end

      it '読書中書籍（reading）は読了期限なしで無効' do
        book = build(:book, deadline: nil, status: :reading)
        expect(book).not_to be_valid
        expect(book.errors[:deadline]).not_to be_empty
      end

      it '読了済み書籍（completed）は読了期限なしで有効' do
        book = build(:book, deadline: nil, status: :completed)
        expect(book).to be_valid
      end

      it '過去読書（is_past_reading: true）は読了期限なしで有効' do
        book = build(:book, deadline: nil)
        book.is_past_reading = 'true'
        expect(book).to be_valid
      end

      it '積読書籍が初回進捗記録で読書中へ遷移する際は読了期限が必須' do
        book = create(:book, deadline: nil, status: :unread, current_page: 0)
        book.current_page = 1
        expect(book).not_to be_valid
        expect(book.errors[:deadline]).not_to be_empty
      end

      it '積読書籍が初回進捗記録で遷移する際、期限があれば有効' do
        book = create(:book, deadline: Date.current + 7, status: :unread, current_page: 0)
        book.current_page = 1
        expect(book).to be_valid
      end

      it '新規作成時に current_page が 1 以上の場合は読了期限が必須' do
        book = build(:book, deadline: nil, status: :unread, current_page: 5)
        expect(book).not_to be_valid
        expect(book.errors[:deadline]).not_to be_empty
      end

      it '新規作成時に current_page が 1 以上で期限があれば有効' do
        book = build(:book, deadline: Date.current + 7, status: :unread, current_page: 5)
        expect(book).to be_valid
      end

      it '今日の日付であれば有効（新規作成時）' do
        expect(build(:book, deadline: Date.current)).to be_valid
      end

      it '過去の日付は無効（新規作成時）' do
        book = build(:book, deadline: Date.current - 1)
        expect(book).not_to be_valid
        expect(book.errors[:deadline]).not_to be_empty
      end

      it '新規作成時は status が completed でも過去日の期限は無効' do
        book = build(:book, deadline: Date.current - 1, status: :completed)
        expect(book).not_to be_valid
        expect(book.errors[:deadline]).not_to be_empty
      end

      it '更新時に期限を過去の日付に変更する場合は無効' do
        book = create(:book, deadline: Date.current + 1)
        book.deadline = Date.current - 1
        expect(book).not_to be_valid
        expect(book.errors[:deadline]).not_to be_empty
      end

      it '更新時に期限を変えずに他の属性を変更する場合は有効' do
        book = create(:book, deadline: Date.current + 1)
        book.title = '変更後のタイトル'
        expect(book).to be_valid
      end

      it '読了済み書籍の編集時は過去の日付でも有効' do
        book = create(:book, deadline: Date.current + 1, status: :completed)
        book.deadline = Date.current - 1
        expect(book).to be_valid
      end

      it '未読書籍の編集時は過去の日付に変更すると無効' do
        book = create(:book, deadline: Date.current + 1, status: :unread)
        book.deadline = Date.current - 1
        expect(book).not_to be_valid
        expect(book.errors[:deadline]).not_to be_empty
      end
    end

    describe 'author' do
      it '著者名がなくても有効' do
        expect(build(:book, author: nil)).to be_valid
      end
    end

    describe 'memo' do
      it '空でも有効' do
        expect(build(:book, memo: '')).to be_valid
      end

      it '2000文字以内であれば有効' do
        expect(build(:book, memo: 'a' * 2000)).to be_valid
      end

      it '2001文字以上は無効' do
        expect(build(:book, memo: 'a' * 2001)).not_to be_valid
      end
    end

    describe 'rating' do
      it 'nilでも有効' do
        expect(build(:book, rating: nil)).to be_valid
      end

      it '1〜5の整数は有効' do
        (1..5).each do |r|
          expect(build(:book, rating: r)).to be_valid
        end
      end

      it '0は無効' do
        expect(build(:book, rating: 0)).not_to be_valid
      end

      it '6は無効' do
        expect(build(:book, rating: 6)).not_to be_valid
      end

      it '小数は無効' do
        expect(build(:book, rating: 3.5)).not_to be_valid
      end
    end

    describe 'review' do
      it '空でも有効' do
        expect(build(:book, review: '')).to be_valid
      end

      it '1000文字以内であれば有効' do
        expect(build(:book, review: 'a' * 1000)).to be_valid
      end

      it '1001文字以上は無効' do
        expect(build(:book, review: 'a' * 1001)).not_to be_valid
      end
    end

    describe 'cover_image_url' do
      it 'nilでも有効' do
        expect(build(:book, cover_image_url: nil)).to be_valid
      end

      it '空文字でも有効' do
        expect(build(:book, cover_image_url: '')).to be_valid
      end

      it '有効なhttpsのURLであれば有効' do
        expect(build(:book, cover_image_url: 'https://cover.openbd.jp/9784873115658.jpg')).to be_valid
      end

      it '有効なhttpのURLであれば有効' do
        expect(build(:book, cover_image_url: 'http://example.com/cover.jpg')).to be_valid
      end

      it 'URLでない文字列は無効' do
        book = build(:book, cover_image_url: 'not-a-url')
        expect(book).not_to be_valid
        expect(book.errors[:cover_image_url]).not_to be_empty
      end

      it 'ftp:// のURLは無効' do
        book = build(:book, cover_image_url: 'ftp://example.com/cover.jpg')
        expect(book).not_to be_valid
        expect(book.errors[:cover_image_url]).not_to be_empty
      end

      it '2048文字以下であれば有効' do
        url = "https://example.com/#{'a' * 2000}"
        expect(build(:book, cover_image_url: url)).to be_valid
      end

      it '2049文字以上は無効' do
        url = "https://example.com/#{'a' * 2050}"
        book = build(:book, cover_image_url: url)
        expect(book).not_to be_valid
        expect(book.errors[:cover_image_url]).not_to be_empty
      end
    end

    describe 'cover_image（Active Storage）' do
      it '添付なしは有効' do
        book = build(:book)
        expect(book.cover_image.attached?).to be false
        expect(book).to be_valid
      end

      it 'JPEG画像は有効' do
        book = build(:book)
        book.cover_image.attach(
          io: StringIO.new("fake jpeg data"),
          filename: 'cover.jpg',
          content_type: 'image/jpeg'
        )
        expect(book).to be_valid
      end

      it 'PNG画像は有効' do
        book = build(:book)
        book.cover_image.attach(
          io: StringIO.new("fake png data"),
          filename: 'cover.png',
          content_type: 'image/png'
        )
        expect(book).to be_valid
      end

      it 'WebP画像は有効' do
        book = build(:book)
        book.cover_image.attach(
          io: StringIO.new("fake webp data"),
          filename: 'cover.webp',
          content_type: 'image/webp'
        )
        expect(book).to be_valid
      end

      it '不正なコンテントタイプは無効' do
        book = build(:book)
        book.cover_image.attach(
          io: StringIO.new("fake gif data"),
          filename: 'cover.gif',
          content_type: 'image/gif'
        )
        expect(book).not_to be_valid
        expect(book.errors[:cover_image]).not_to be_empty
      end

      it '5MBを超えるファイルは無効' do
        book = build(:book)
        large_data = 'a' * (5.megabytes + 1)
        book.cover_image.attach(
          io: StringIO.new(large_data),
          filename: 'large.jpg',
          content_type: 'image/jpeg'
        )
        expect(book).not_to be_valid
        expect(book.errors[:cover_image]).not_to be_empty
      end

      it '2冊連続で書影を添付しても先に登録した書影が維持される' do
        user = create(:user)
        book1 = create(:book, user: user)
        book2 = create(:book, user: user)

        file_data = Rails.root.join('spec/fixtures/files/test_cover.png').binread

        book1.cover_image.attach(
          io: StringIO.new(file_data),
          filename: 'cover-1.png',
          content_type: 'image/png'
        )

        first_blob_id = book1.cover_image.blob.id

        book2.cover_image.attach(
          io: StringIO.new(file_data),
          filename: 'cover-2.png',
          content_type: 'image/png'
        )

        expect(book1.reload.cover_image).to be_attached
        expect(book2.reload.cover_image).to be_attached
        expect(book1.cover_image.blob.id).to eq(first_blob_id)
      end
    end

    describe 'category' do
      it '種類がない場合は無効' do
        book = build(:book)
        book.category = nil
        expect(book).not_to be_valid
      end
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーに属する' do
      book = build(:book)
      expect(book.user).to be_present
    end
  end

  describe 'enum: status' do
    it 'unread（未読）を持つ' do
      book = build(:book, status: :unread)
      expect(book).to be_unread
    end

    it 'reading（読書中）を持つ' do
      book = build(:book, status: :reading)
      expect(book).to be_reading
    end

    it 'completed（読了）を持つ' do
      book = build(:book, status: :completed)
      expect(book).to be_completed
    end

    it 'デフォルトのステータスは unread' do
      book = create(:book)
      expect(book.reload).to be_unread
    end
  end

  describe 'enum: category' do
    it '各種類を正しく定義していること' do
      expect(build(:book, category: :technical)).to be_technical
      expect(build(:book, category: :literature)).to be_literature
      expect(build(:book, category: :entertainment)).to be_entertainment
      expect(build(:book, category: :manga)).to be_manga
      expect(build(:book, category: :essay)).to be_essay
      expect(build(:book, category: :practical)).to be_practical
      expect(build(:book, category: :magazine)).to be_magazine
      expect(build(:book, category: :academic)).to be_academic
      expect(build(:book, category: :non_fiction)).to be_non_fiction
      expect(build(:book, category: :humanities)).to be_humanities
      expect(build(:book, category: :other)).to be_other
    end

    it 'デフォルトの種類は other' do
      user = create(:user)
      book = Book.create!(user: user, title: 'テスト本', pages: 100)
      expect(book.reload).to be_other
    end
  end

  describe '#daily_quota' do
    context '読了済みの場合' do
      it '0を返す' do
        book = build(:book, status: :completed, current_page: 300, pages: 300)
        expect(book.daily_quota).to eq(0)
      end
    end

    context 'ページ数に到達している場合' do
      it '0を返す' do
        book = build(:book, current_page: 300, pages: 300, deadline: Date.current + 10)
        expect(book.daily_quota).to eq(0)
      end
    end

    context '通常の場合（残ページ / 残日数、切り上げ）' do
      it '切り上げされたノルマを返す' do
        # 残ページ: 300 - 0 = 300, 残日数: 10日（今日含む）, ノルマ: ceil(300/10) = 30
        book = build(:book, current_page: 0, pages: 300, deadline: Date.current + 9)
        expect(book.daily_quota).to eq(30)
      end

      it '割り切れない場合は切り上げを返す' do
        # 残ページ: 100, 残日数: 3日（今日含む）, ノルマ: ceil(100/3) = 34
        book = build(:book, current_page: 0, pages: 100, deadline: Date.current + 2)
        expect(book.daily_quota).to eq(34)
      end
    end

    context '期限超過の場合（期限翌日以降）' do
      it '残日数を1日として計算する' do
        # 残ページ: 100, days_remaining = 0（期限の翌日）→ D=1 として計算
        book = build(:book, current_page: 0, pages: 100, deadline: Date.current - 1)
        expect(book.daily_quota).to eq(100)
      end

      it '期限を5日過ぎた場合も1日として計算する' do
        book = build(:book, current_page: 0, pages: 50, deadline: Date.current - 5)
        expect(book.daily_quota).to eq(50)
      end
    end
  end

  describe '#progress_percentage' do
    it '読了済みの場合は100を返す' do
      book = build(:book, status: :completed)
      expect(book.progress_percentage).to eq(100)
    end

    it '現在ページ0の場合は0を返す' do
      book = build(:book, current_page: 0, pages: 300)
      expect(book.progress_percentage).to eq(0)
    end

    it '正しい進捗率を返す（四捨五入）' do
      book = build(:book, current_page: 150, pages: 300)
      expect(book.progress_percentage).to eq(50)
    end

    it '端数は四捨五入される' do
      book = build(:book, current_page: 1, pages: 3)
      # (1/3 * 100).round = 33
      expect(book.progress_percentage).to eq(33)
    end
  end

  describe '#days_remaining' do
    it '期限まで10日の場合は11を返す（今日を含む）' do
      book = build(:book, deadline: Date.current + 10)
      expect(book.days_remaining).to eq(11)
    end

    it '期限当日は1を返す（今日を含む）' do
      book = build(:book, deadline: Date.current)
      expect(book.days_remaining).to eq(1)
    end

    it '期限を3日過ぎた場合は-2を返す' do
      book = build(:book, deadline: Date.current - 3)
      expect(book.days_remaining).to eq(-2)
    end
  end

  describe '#overdue?' do
    it '期限当日は期限超過ではない' do
      book = build(:book, deadline: Date.current)
      expect(book.overdue?).to be false
    end

    it '期限翌日は期限超過となる' do
      book = build(:book, deadline: Date.current - 1)
      expect(book.overdue?).to be true
    end

    it '期限を5日過ぎた場合は期限超過となる' do
      book = build(:book, deadline: Date.current - 5)
      expect(book.overdue?).to be true
    end

    it '期限まで3日ある場合は期限超過ではない' do
      book = build(:book, deadline: Date.current + 3)
      expect(book.overdue?).to be false
    end
  end

  describe '#deadline_urgency_class' do
    it '読了済みの場合は空文字を返す' do
      book = build(:book, status: :completed, deadline: Date.current)
      expect(book.deadline_urgency_class).to eq('')
    end

    it '残り8日以上の場合は空文字を返す' do
      book = build(:book, deadline: Date.current + 8)
      expect(book.deadline_urgency_class).to eq('')
    end

    it '残り7日（ちょうど）の場合は urgent-low を返す' do
      book = build(:book, deadline: Date.current + 6)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-low')
    end

    it '残り4日の場合は urgent-low を返す' do
      book = build(:book, deadline: Date.current + 4)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-low')
    end

    it '残り3日（ちょうど）の場合は urgent-medium を返す' do
      book = build(:book, deadline: Date.current + 2)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-medium')
    end

    it '残り2日の場合は urgent-medium を返す' do
      book = build(:book, deadline: Date.current + 2)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-medium')
    end

    it '残り1日（ちょうど）の場合は urgent-high を返す' do
      book = build(:book, deadline: Date.current)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-high')
    end

    it '期限当日の場合は urgent-high を返す' do
      book = build(:book, deadline: Date.current)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-high')
    end

    it '期限を過ぎた場合は urgent-high を返す' do
      book = build(:book, deadline: Date.current - 1)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-high')
    end
  end

  describe '.for_index_list' do
    let(:user) { create(:user) }

    it '未了本を期限が近い順に並べる' do
      book_far   = create(:book, user: user, deadline: Date.current + 30, status: :unread)
      book_near  = create(:book, user: user, deadline: Date.current + 3, status: :reading)
      book_mid   = create(:book, user: user, deadline: Date.current + 10, status: :unread)

      result = Book.where(user: user).for_index_list
      expect(result.map(&:id)).to eq([ book_near.id, book_mid.id, book_far.id ])
    end

    it '読了済みの本が最後に表示される' do
      book_completed = create(:book, user: user, deadline: Date.current + 1, status: :completed)
      book_unread    = create(:book, user: user, deadline: Date.current + 10, status: :unread)

      result = Book.where(user: user).for_index_list
      expect(result.last.id).to eq(book_completed.id)
      expect(result.first.id).to eq(book_unread.id)
    end

    it '読了済みの本が複数ある場合は読了日の新しい順に並ぶ' do
      book_completed_old  = create(:book, user: user, status: :completed, completed_at: 10.days.ago)
      book_completed_new  = create(:book, user: user, status: :completed, completed_at: 2.days.ago)
      book_unread         = create(:book, user: user, deadline: Date.current + 15, status: :unread)

      result = Book.where(user: user).for_index_list
      expect(result.first.id).to eq(book_unread.id)
      expect(result.second.id).to eq(book_completed_new.id)
      expect(result.last.id).to eq(book_completed_old.id)
    end
  end

  describe '.filtered_for_index' do
    let(:user) { create(:user) }
    let!(:programming) { create(:book, user: user, title: 'Ruby本', genre: 'プログラミング', status: :unread) }
    let!(:business) { create(:book, user: user, title: '戦略本', genre: 'ビジネス', status: :unread) }

    it 'ジャンルで部分一致検索できる' do
      result = user.books.filtered_for_index(genre: 'プログラ', title: nil, author: nil, completed_from: nil, completed_to: nil)

      expect(result).to include(programming)
      expect(result).not_to include(business)
    end

    it 'ジャンルとタイトルの複合条件で検索できる' do
      result = user.books.filtered_for_index(genre: 'プログラ', title: 'Ruby', author: nil, completed_from: nil, completed_to: nil)

      expect(result).to include(programming)
      expect(result).not_to include(business)
    end

    context '出版社検索' do
      let!(:oreilly_book) { create(:book, user: user, publisher: 'オライリー・ジャパン', status: :unread) }
      let!(:other_book)   { create(:book, user: user, publisher: '講談社', status: :unread) }

      it '出版社で部分一致検索できる' do
        result = user.books.filtered_for_index(publisher: 'オライリー')
        expect(result).to include(oreilly_book)
        expect(result).not_to include(other_book)
      end

      it '出版社が空の場合は絞り込まない' do
        result = user.books.filtered_for_index(publisher: nil)
        expect(result).to include(oreilly_book)
        expect(result).to include(other_book)
      end
    end

    context '翻訳者検索' do
      let!(:translated_book) { create(:book, user: user, translator: '田中太郎', status: :unread) }
      let!(:no_translator)   { create(:book, user: user, translator: nil, status: :unread) }

      it '翻訳者で部分一致検索できる' do
        result = user.books.filtered_for_index(translator: '田中')
        expect(result).to include(translated_book)
        expect(result).not_to include(no_translator)
      end

      it '翻訳者が空の場合は絞り込まない' do
        result = user.books.filtered_for_index(translator: nil)
        expect(result).to include(translated_book)
        expect(result).to include(no_translator)
      end
    end
  end


  describe 'コールバック' do
    describe '#auto_set_reading_status (before_save)' do
      context 'ステータスが unread の場合' do
        it 'current_page が 0 から 1 以上に変更されると reading になる' do
          book = create(:book, status: :unread, current_page: 0)
          book.update!(current_page: 1)
          expect(book.reload).to be_reading
        end

        it 'current_page が 0 から大きい値に変更されても reading になる' do
          book = create(:book, status: :unread, current_page: 0)
          book.update!(current_page: 50)
          expect(book.reload).to be_reading
        end

        it 'current_page が 0 のまま他の属性を変更してもステータスは変わらない' do
          book = create(:book, status: :unread, current_page: 0)
          book.update!(title: '別のタイトル')
          expect(book.reload).to be_unread
        end

        it 'current_page を 0 のまま保存してもステータスは変わらない' do
          book = create(:book, status: :unread, current_page: 0)
          book.current_page = 0
          book.save!
          expect(book.reload).to be_unread
        end
      end

      context 'ステータスが reading の場合' do
        it 'current_page が更新されてもステータスは reading のまま' do
          book = create(:book, status: :reading, current_page: 1)
          book.update!(current_page: 2)
          expect(book.reload).to be_reading
        end
      end

      context 'ステータスが completed の場合' do
        it 'current_page を変更してもステータスは completed のまま' do
          book = create(:book, status: :completed, current_page: 300, pages: 300)
          book.update!(current_page: 200)
          expect(book.reload).to be_completed
        end
      end

      context '新規作成時' do
        it '新規作成で current_page が 1 以上の場合、ステータスが reading になる' do
          book = build(:book, status: :unread, current_page: 5, deadline: Date.current + 7)
          book.save!
          expect(book.reload).to be_reading
        end

        it '新規作成で current_page が 0 の場合、ステータスは unread のまま' do
          book = build(:book, status: :unread, current_page: 0)
          book.save!
          expect(book.reload).to be_unread
        end
      end
    end

    describe '#create_reading_log_for_past_reading (after_create)' do
      context '過去読書チェックを有効にして新規作成された場合' do
        it '全ページ分の読書ログ（ReadingLog）が自動で作成されること' do
          book = build(:book, pages: 300, is_past_reading: 'true', completed_at_input: '2026-06-01')
          expect { book.save! }.to change(ReadingLog, :count).by(1)

          log = book.reading_logs.last
          expect(log.pages_read).to eq(300)
          expect(log.read_at).to eq(Date.parse('2026-06-01'))
          expect(log.start_page).to eq(1)
          expect(log.end_page).to eq(300)
        end
      end

      context '過去読書チェックを無効にして新規作成された場合（通常の読了本データ作成など）' do
        it '読書ログは作成されないこと' do
          book = build(:book, pages: 300, is_past_reading: 'false', status: :completed)
          expect { book.save! }.not_to change(ReadingLog, :count)
        end
      end

      context 'ステータスが completed 以外（unreadなど）で新規作成された場合' do
        it '読書ログは作成されないこと' do
          book = build(:book, pages: 300, is_past_reading: 'false', status: :unread)
          expect { book.save! }.not_to change(ReadingLog, :count)
        end
      end
    end
  end

  describe 'ビジネスロジック' do
    describe '#remaining_pages' do
      it 'ページ数から現在ページを引いた値を返す' do
        book = build(:book, pages: 300, current_page: 100)
        expect(book.remaining_pages).to eq(200)
      end
    end

    describe '#progress_percentage' do
      it '進捗率を返す' do
        book = build(:book, pages: 200, current_page: 100)
        expect(book.progress_percentage).to eq(50)
      end

      it '未読の場合は0を返す' do
        book = build(:book, pages: 200, current_page: 0)
        expect(book.progress_percentage).to eq(0)
      end
    end
  end

  describe '#extend_deadline!' do
    let(:book) { create(:book, deadline: Date.current + 7, extension_count: 0) }

    context '期限が未設定（nil）の状態で日付を渡した場合' do
      let(:book_without_deadline) { create(:book, deadline: nil, status: :unread, extension_count: 0) }

      it 'deadlineが設定される' do
        book_without_deadline.extend_deadline!(Date.current + 14)
        expect(book_without_deadline.reload.deadline).to eq(Date.current + 14)
      end

      it 'extension_countはインクリメントされない（初回設定のため）' do
        book_without_deadline.extend_deadline!(Date.current + 14)
        expect(book_without_deadline.reload.extension_count).to eq(0)
      end

      it 'trueを返す' do
        expect(book_without_deadline.extend_deadline!(Date.current + 14)).to be_truthy
      end
    end

    context '現在の期限より後の日付を渡した場合' do
      it 'deadlineが更新される' do
        new_deadline = Date.current + 14
        book.extend_deadline!(new_deadline)
        expect(book.reload.deadline).to eq(new_deadline)
      end

      it 'extension_countがインクリメントされる' do
        book.extend_deadline!(Date.current + 14)
        expect(book.reload.extension_count).to eq(1)
      end

      it 'trueを返す' do
        expect(book.extend_deadline!(Date.current + 14)).to be_truthy
      end
    end

    context '現在の期限と同じ日付を渡した場合' do
      it 'falseを返す' do
        expect(book.extend_deadline!(Date.current + 7)).to be_falsey
      end

      it 'deadlineが変更されない' do
        book.extend_deadline!(Date.current + 7)
        expect(book.reload.deadline).to eq(Date.current + 7)
      end

      it 'extension_countが変わらない' do
        book.extend_deadline!(Date.current + 7)
        expect(book.reload.extension_count).to eq(0)
      end
    end

    context '現在の期限より前の日付を渡した場合' do
      it 'falseを返す' do
        expect(book.extend_deadline!(Date.current + 3)).to be_falsey
      end

      it 'deadlineが変更されない' do
        book.extend_deadline!(Date.current + 3)
        expect(book.reload.deadline).to eq(Date.current + 7)
      end
    end
  end

  describe '重複タイトルと再読記録関連' do
    let(:user) { create(:user) }

    describe '.normalize_title / #normalize_title' do
      it '全角半角、大文字小文字、空白を正規化すること' do
        expect(Book.normalize_title("Ruby on Rails ")).to eq("ruby on rails")
        expect(Book.normalize_title("リーダブルコード")).to eq(Book.normalize_title(" ﾘｰﾀﾞﾌﾞﾙｺｰﾄﾞ "))
      end
    end

    describe '保存時の自動正規化' do
      it '保存時に normalized_title が自動で設定されること' do
        book = create(:book, user: user, title: " Ruby on Rails ")
        expect(book.normalized_title).to eq("ruby on rails")
      end
    end

    describe '回数と前回の本と表示タイトルの判定' do
      let!(:book1) { create(:book, user: user, title: "リーダブルコード", created_at: 3.days.ago) }
      let!(:book2) { create(:book, user: user, title: " ﾘｰﾀﾞﾌﾞﾙｺｰﾄﾞ ", created_at: 2.days.ago) }
      let!(:book3) { create(:book, user: user, title: "リーダブルコード", created_at: 1.day.ago) }
      let!(:other_book) { create(:book, user: user, title: "デザインパターン") }

      context '1冊目の場合' do
        it '回数は1であること' do
          expect(book1.reading_round).to eq(1)
        end

        it '表示タイトルはそのままのタイトルであること' do
          expect(book1.display_title).to eq("リーダブルコード")
        end

        it '前回の本は nil であること' do
          expect(book1.previous_book).to be_nil
        end
      end

      context '2冊目の場合' do
        it '回数は2であること' do
          expect(book2.reading_round).to eq(2)
        end

        it '表示タイトルに回数が付与されること' do
          expect(book2.display_title).to eq(" ﾘｰﾀﾞﾌﾞﾙｺｰﾄﾞ (2回目)")
        end

        it '前回の本は 1冊目の本であること' do
          expect(book2.previous_book).to eq(book1)
        end
      end

      context '3冊目の場合' do
        it '回数は3であること' do
          expect(book3.reading_round).to eq(3)
        end

        it '表示タイトルに回数が付与されること' do
          expect(book3.display_title).to eq("リーダブルコード(3回目)")
        end

        it '前回の本は 2冊目の本であること' do
          expect(book3.previous_book).to eq(book2)
        end
      end

      context '異なるタイトルの場合' do
        it '回数は1であること' do
          expect(other_book.reading_round).to eq(1)
        end

        it '前回の本は nil であること' do
          expect(other_book.previous_book).to be_nil
        end
      end

      context '新規レコード（未保存）の場合' do
        it 'まだ保存されていない場合も、すでに登録されている数+1を返すこと' do
          new_book = build(:book, user: user, title: "リーダブルコード")
          expect(new_book.reading_round).to eq(4)
        end
      end
    end
  end

  describe '詳細画面の前後ナビゲーション（Issue #376）' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:book1) { create(:book, user: user) }
    let!(:book2) { create(:book, user: user) }
    let!(:book3) { create(:book, user: user) }
    let!(:other_book) { create(:book, user: other_user) }

    describe '#prev_book_by_id' do
      context '最初の本（最小 id）の場合' do
        it 'nil を返すこと' do
          expect(book1.prev_book_by_id).to be_nil
        end
      end

      context '中間の本の場合' do
        it '1つ前の本を返すこと' do
          expect(book2.prev_book_by_id).to eq(book1)
        end
      end

      context '最後の本の場合' do
        it '1つ前の本を返すこと' do
          expect(book3.prev_book_by_id).to eq(book2)
        end
      end

      context '他ユーザーの本が存在する場合' do
        it '他ユーザーの本は返さないこと' do
          # other_book の id が book1 より小さい場合でも対象外
          expect(book1.prev_book_by_id).to be_nil
        end
      end

      context '新規レコード（未保存）の場合' do
        it 'nil を返すこと' do
          new_book = build(:book, user: user)
          expect(new_book.prev_book_by_id).to be_nil
        end
      end
    end

    describe '#next_book_by_id' do
      context '最初の本の場合' do
        it '1つ後の本を返すこと' do
          expect(book1.next_book_by_id).to eq(book2)
        end
      end

      context '中間の本の場合' do
        it '1つ後の本を返すこと' do
          expect(book2.next_book_by_id).to eq(book3)
        end
      end

      context '最後の本（最大 id）の場合' do
        it 'nil を返すこと' do
          expect(book3.next_book_by_id).to be_nil
        end
      end

      context '他ユーザーの本が存在する場合' do
        it '他ユーザーの本は返さないこと' do
          # other_book の id が book3 より大きい場合でも対象外
          expect(book3.next_book_by_id).to be_nil
        end
      end

      context '新規レコード（未保存）の場合' do
        it 'nil を返すこと' do
          new_book = build(:book, user: user)
          expect(new_book.next_book_by_id).to be_nil
        end
      end
    end
  end
end
