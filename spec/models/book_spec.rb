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
end
