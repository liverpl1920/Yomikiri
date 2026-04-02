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

      it '今日の日付であれば有効（新規作成時）' do
        expect(build(:book, deadline: Date.current)).to be_valid
      end

      it '過去の日付は無効（新規作成時）' do
        book = build(:book, deadline: Date.current - 1)
        expect(book).not_to be_valid
        expect(book.errors[:deadline]).not_to be_empty
      end

      it '過去の日付でも更新時は有効' do
        book = create(:book, deadline: Date.current + 1)
        book.deadline = Date.current - 1
        expect(book).to be_valid
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

  describe 'ビジネスロジック' do
    describe '#remaining_pages' do
      it '読了対象ページ数から現在ページを引いた値を返す' do
        book = build(:book, target_pages: 300, current_page: 100)
        expect(book.remaining_pages).to eq(200)
      end
    end

    describe '#remaining_days' do
      it '今日を含む残日数を返す' do
        book = build(:book, deadline: Date.current)
        expect(book.remaining_days).to eq(1)
      end

      it '明日が期限の場合は2を返す' do
        book = build(:book, deadline: Date.current + 1)
        expect(book.remaining_days).to eq(2)
      end

      it '期限が過去の場合は0を返す' do
        book = build(:book, deadline: Date.current - 1)
        expect(book.remaining_days).to eq(0)
      end
    end

    describe '#calculate_daily_quota' do
      it '残ページ / 残日数の切り上げを返す' do
        book = build(:book, target_pages: 100, current_page: 0, deadline: Date.current + 9)
        # 残100ページ / 残10日 = 10ページ
        expect(book.calculate_daily_quota).to eq(10)
      end

      it '割り切れない場合は切り上げる' do
        book = build(:book, target_pages: 101, current_page: 0, deadline: Date.current + 9)
        # 残101ページ / 残10日 = 10.1 → 11
        expect(book.calculate_daily_quota).to eq(11)
      end

      it '残ページが0の場合は0を返す' do
        book = build(:book, target_pages: 100, current_page: 100, deadline: Date.current + 1)
        expect(book.calculate_daily_quota).to eq(0)
      end
    end

    describe '#progress_percentage' do
      it '進捗率を返す' do
        book = build(:book, target_pages: 200, current_page: 100)
        expect(book.progress_percentage).to eq(50.0)
      end

      it '未読の場合は0を返す' do
        book = build(:book, target_pages: 200, current_page: 0)
        expect(book.progress_percentage).to eq(0.0)
      end
    end
  end
end
