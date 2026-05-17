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

    describe 'total_pages' do
      it '総ページ数がない場合は無効' do
        expect(build(:book, total_pages: nil)).not_to be_valid
      end

      it '総ページ数が0の場合は無効' do
        expect(build(:book, total_pages: 0)).not_to be_valid
      end

      it '総ページ数が1以上であれば有効' do
        expect(build(:book, total_pages: 1, target_pages: 1)).to be_valid
      end

      it '総ページ数が小数の場合は無効' do
        expect(build(:book, total_pages: 1.5)).not_to be_valid
      end
    end

    describe 'target_pages' do
      it '読了対象ページ数がない場合は無効' do
        expect(build(:book, target_pages: nil)).not_to be_valid
      end

      it '読了対象ページ数が0の場合は無効' do
        expect(build(:book, target_pages: 0)).not_to be_valid
      end

      it '読了対象ページ数が総ページ数以下であれば有効' do
        expect(build(:book, total_pages: 300, target_pages: 250)).to be_valid
      end

      it '読了対象ページ数が総ページ数を超える場合は無効' do
        expect(build(:book, total_pages: 300, target_pages: 301)).not_to be_valid
      end
    end

    describe 'current_page' do
      it '現在ページがない場合は無効' do
        expect(build(:book, current_page: nil)).not_to be_valid
      end

      it '現在ページが0であれば有効' do
        expect(build(:book, current_page: 0)).to be_valid
      end

      it '現在ページが読了対象ページ数以下であれば有効' do
        expect(build(:book, target_pages: 300, current_page: 300)).to be_valid
      end

      it '現在ページが読了対象ページ数を超える場合は無効' do
        expect(build(:book, target_pages: 300, current_page: 301)).not_to be_valid
      end

      it '現在ページが負の値の場合は無効' do
        expect(build(:book, current_page: -1)).not_to be_valid
      end

      it '現在ページが総ページ数以下であれば有効' do
        expect(build(:book, total_pages: 300, target_pages: 300, current_page: 300)).to be_valid
      end

      it '現在ページが総ページ数を超える場合は無効' do
        expect(build(:book, total_pages: 300, target_pages: 300, current_page: 301)).not_to be_valid
      end

      it '現在ページが総ページ数を超える場合に専用エラーキーが付与される' do
        book = build(:book, total_pages: 200, target_pages: 200, current_page: 201)

        book.validate

        expect(book.errors.details[:current_page]).to include(include(error: :less_than_or_equal_to_total_pages, count: 200))
      end
    end

    describe 'deadline' do
      it '読了期限がない場合は無効' do
        expect(build(:book, deadline: nil)).not_to be_valid
      end

      it '今日の日付であれば有効（新規作成時）' do
        expect(build(:book, deadline: Date.current)).to be_valid
      end

      it '過去の日付は無効（新規作成時）' do
        book = build(:book, deadline: Date.current - 1)
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
    end

    describe 'author' do
      it '著者名がなくても有効' do
        expect(build(:book, author: nil)).to be_valid
      end
    end

    describe 'genre' do
      it 'ジャンルがなくても有効' do
        expect(build(:book, genre: nil)).to be_valid
      end

      it 'ジャンルが100文字以内なら有効' do
        expect(build(:book, genre: 'a' * 100)).to be_valid
      end

      it 'ジャンルが101文字以上なら無効' do
        expect(build(:book, genre: 'a' * 101)).not_to be_valid
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

  describe '#daily_quota' do
    context '読了済みの場合' do
      it '0を返す' do
        book = build(:book, status: :completed, current_page: 300, target_pages: 300)
        expect(book.daily_quota).to eq(0)
      end
    end

    context '読了対象ページ数に到達している場合' do
      it '0を返す' do
        book = build(:book, current_page: 300, target_pages: 300, deadline: Date.current + 10)
        expect(book.daily_quota).to eq(0)
      end
    end

    context '通常の場合（残ページ / 残日数、切り上げ）' do
      it '切り上げされたノルマを返す' do
        # 残ページ: 300 - 0 = 300, 残日数: 10日（今日含む）, ノルマ: ceil(300/10) = 30
        book = build(:book, current_page: 0, target_pages: 300, deadline: Date.current + 9)
        expect(book.daily_quota).to eq(30)
      end

      it '割り切れない場合は切り上げを返す' do
        # 残ページ: 100, 残日数: 3日（今日含む）, ノルマ: ceil(100/3) = 34
        book = build(:book, current_page: 0, target_pages: 100, deadline: Date.current + 2)
        expect(book.daily_quota).to eq(34)
      end
    end

    context '期限超過の場合（期限翌日以降）' do
      it '残日数を1日として計算する' do
        # 残ページ: 100, days_remaining = 0（期限の翌日）→ D=1 として計算
        book = build(:book, current_page: 0, target_pages: 100, deadline: Date.current - 1)
        expect(book.daily_quota).to eq(100)
      end

      it '期限を5日過ぎた場合も1日として計算する' do
        book = build(:book, current_page: 0, target_pages: 50, deadline: Date.current - 5)
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
      book = build(:book, current_page: 0, target_pages: 300)
      expect(book.progress_percentage).to eq(0)
    end

    it '正しい進捗率を返す（四捨五入）' do
      book = build(:book, current_page: 150, target_pages: 300)
      expect(book.progress_percentage).to eq(50)
    end

    it '端数は四捨五入される' do
      book = build(:book, current_page: 1, target_pages: 3)
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

    it '読了済みの本が複数ある場合も期限順に並ぶ' do
      book_completed_far  = create(:book, user: user, deadline: Date.current + 20, status: :completed)
      book_completed_near = create(:book, user: user, deadline: Date.current + 5, status: :completed)
      book_unread         = create(:book, user: user, deadline: Date.current + 15, status: :unread)

      result = Book.where(user: user).for_index_list
      expect(result.first.id).to eq(book_unread.id)
      expect(result.second.id).to eq(book_completed_near.id)
      expect(result.last.id).to eq(book_completed_far.id)
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
          book = create(:book, status: :completed, current_page: 300, target_pages: 300)
          book.update!(current_page: 200)
          expect(book.reload).to be_completed
        end
      end

      context '新規作成時' do
        it '新規作成では current_page が 0 以外でもステータスを自動変更しない' do
          book = build(:book, status: :unread, current_page: 5)
          book.save!
          expect(book.reload).to be_unread
        end
      end
    end
  end

  describe 'ビジネスロジック' do
    describe '#remaining_pages' do
      it '読了対象ページ数から現在ページを引いた値を返す' do
        book = build(:book, target_pages: 300, current_page: 100)
        expect(book.remaining_pages).to eq(200)
      end
    end

    describe '#progress_percentage' do
      it '進捗率を返す' do
        book = build(:book, target_pages: 200, current_page: 100)
        expect(book.progress_percentage).to eq(50)
      end

      it '未読の場合は0を返す' do
        book = build(:book, target_pages: 200, current_page: 0)
        expect(book.progress_percentage).to eq(0)
      end
    end
  end

  describe '#extend_deadline!' do
    let(:book) { create(:book, deadline: Date.current + 7, extension_count: 0) }

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
end
