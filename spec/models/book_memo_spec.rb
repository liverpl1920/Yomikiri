require 'rails_helper'

RSpec.describe BookMemo, type: :model do
  describe 'ファクトリ' do
    it '有効なファクトリを持つ' do
      expect(build(:book_memo)).to be_valid
    end
  end

  describe 'バリデーション' do
    describe 'content' do
      it 'contentがない場合は無効' do
        expect(build(:book_memo, content: '')).not_to be_valid
      end

      it 'contentがnilの場合は無効' do
        expect(build(:book_memo, content: nil)).not_to be_valid
      end

      it 'contentが2000文字以内であれば有効' do
        expect(build(:book_memo, content: 'a' * 2000)).to be_valid
      end

      it 'contentが2001文字以上の場合は無効' do
        expect(build(:book_memo, content: 'a' * 2001)).not_to be_valid
      end
    end
  end

  describe 'アソシエーション' do
    it 'bookに属している' do
      expect(BookMemo.reflect_on_association(:book).macro).to eq(:belongs_to)
    end
  end

  describe 'スコープ' do
    describe '.latest_first' do
      it '新しい順で返す' do
        book = create(:book)
        old_memo = create(:book_memo, book: book, created_at: 2.days.ago)
        new_memo = create(:book_memo, book: book, created_at: 1.day.ago)

        expect(book.book_memos.latest_first).to eq([ new_memo, old_memo ])
      end
    end
  end
end
