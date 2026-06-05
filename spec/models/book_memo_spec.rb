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

    describe 'page_number' do
      it 'page_numberが空白の場合は有効' do
        expect(build(:book_memo, page_number: '')).to be_valid
      end

      it 'page_numberがnilの場合は有効' do
        expect(build(:book_memo, page_number: nil)).to be_valid
      end

      it 'page_numberが20文字以内であれば有効' do
        expect(build(:book_memo, page_number: 'a' * 20)).to be_valid
      end

      it 'page_numberが21文字以上の場合は無効' do
        expect(build(:book_memo, page_number: 'a' * 21)).not_to be_valid
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

    describe '.content_like' do
      let(:book) { create(:book) }
      let!(:matching_memo) { create(:book_memo, book: book, content: '重要なポイントはここです') }
      let!(:other_memo) { create(:book_memo, book: book, content: '別の内容') }

      it '部分一致するメモを返す' do
        expect(BookMemo.content_like('重要')).to include(matching_memo)
        expect(BookMemo.content_like('重要')).not_to include(other_memo)
      end

      it '大文字小文字を区別しない' do
        memo = create(:book_memo, book: book, content: 'Ruby on Rails')
        expect(BookMemo.content_like('ruby')).to include(memo)
      end

      it 'キーワードに一致しない場合は空を返す' do
        expect(BookMemo.content_like('存在しないキーワード')).to be_empty
      end
    end
  end


  describe 'インスタンスメソッド' do
    describe '#edited?' do
      it '作成直後は編集済みではない' do
        memo = create(:book_memo)
        expect(memo.edited?).to be false
      end

      it 'updated_atがcreated_atより1秒以上後の場合は編集済みである' do
        memo = create(:book_memo, created_at: 10.minutes.ago, updated_at: 5.minutes.ago)
        expect(memo.edited?).to be true
      end

      it 'updated_atとcreated_atの差が1秒以内の場合は編集済みではない' do
        now = Time.current
        memo = create(:book_memo, created_at: now, updated_at: now + 0.5.seconds)
        expect(memo.edited?).to be false
      end

      it 'updated_atとcreated_atの差がちょうど1秒の場合は編集済みではない' do
        now = Time.current
        memo = create(:book_memo, created_at: now, updated_at: now + 1.second)
        expect(memo.edited?).to be false
      end
    end
  end
end
