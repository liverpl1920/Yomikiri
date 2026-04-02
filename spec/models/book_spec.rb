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
    end

    describe 'deadline' do
      it '読了期限がない場合は無効' do
        expect(build(:book, deadline: nil)).not_to be_valid
      end
    end

    describe 'author' do
      it '著者名がなくても有効' do
        expect(build(:book, author: nil)).to be_valid
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
        # 残ページ: 300 - 0 = 300, 残日数: 10日, ノルマ: ceil(300/10) = 30
        book = build(:book, current_page: 0, target_pages: 300, deadline: Date.current + 10)
        expect(book.daily_quota).to eq(30)
      end

      it '割り切れない場合は切り上げを返す' do
        # 残ページ: 100, 残日数: 3日, ノルマ: ceil(100/3) = 34
        book = build(:book, current_page: 0, target_pages: 100, deadline: Date.current + 3)
        expect(book.daily_quota).to eq(34)
      end
    end

    context '残日数が0以下（期限当日または過ぎた場合）' do
      it '残日数を1日として計算する' do
        # 残ページ: 100, 残日数: max(0,1)=1, ノルマ: 100
        book = build(:book, current_page: 0, target_pages: 100, deadline: Date.current)
        expect(book.daily_quota).to eq(100)
      end

      it '期限が過ぎた場合も1日として計算する' do
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
    it '期限まで10日の場合は10を返す' do
      book = build(:book, deadline: Date.current + 10)
      expect(book.days_remaining).to eq(10)
    end

    it '期限当日は0を返す' do
      book = build(:book, deadline: Date.current)
      expect(book.days_remaining).to eq(0)
    end

    it '期限を過ぎた場合は負の値を返す' do
      book = build(:book, deadline: Date.current - 3)
      expect(book.days_remaining).to eq(-3)
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
      book = build(:book, deadline: Date.current + 7)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-low')
    end

    it '残り4日の場合は urgent-low を返す' do
      book = build(:book, deadline: Date.current + 4)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-low')
    end

    it '残り3日（ちょうど）の場合は urgent-medium を返す' do
      book = build(:book, deadline: Date.current + 3)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-medium')
    end

    it '残り2日の場合は urgent-medium を返す' do
      book = build(:book, deadline: Date.current + 2)
      expect(book.deadline_urgency_class).to eq('book-card__cover--urgent-medium')
    end

    it '残り1日（ちょうど）の場合は urgent-high を返す' do
      book = build(:book, deadline: Date.current + 1)
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
end
