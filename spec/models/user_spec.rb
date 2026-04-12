require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it '有効なファクトリを持つ' do
      expect(build(:user)).to be_valid
    end

    it 'メールアドレスがない場合は無効' do
      expect(build(:user, email: '')).not_to be_valid
    end

    it 'パスワードがない場合は無効' do
      expect(build(:user, password: '')).not_to be_valid
    end

    it 'ニックネームが50文字以内であれば有効' do
      expect(build(:user, nickname: 'a' * 50)).to be_valid
    end

    it 'ニックネームが51文字以上の場合は無効' do
      expect(build(:user, nickname: 'a' * 51)).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    # Book モデルは Issue #13 で実装予定のため、実装後にテストを有効化する
    # it { is_expected.to have_many(:books).dependent(:destroy) }
  end

  describe '#completed_books_count' do
    let(:user) { create(:user) }

    it '読了した本の冊数を返す' do
      create(:book, user: user, status: :completed)
      create(:book, user: user, status: :completed)
      create(:book, user: user, status: :reading)

      expect(user.completed_books_count).to eq(2)
    end

    it '読了した本がない場合は0を返す' do
      create(:book, user: user, status: :reading)

      expect(user.completed_books_count).to eq(0)
    end
  end

  describe '#completed_pages_total' do
    let(:user) { create(:user) }

    it '読了した本の target_pages 合計を返す' do
      create(:book, user: user, status: :completed, target_pages: 200, total_pages: 300)
      create(:book, user: user, status: :completed, target_pages: 150, total_pages: 200)
      create(:book, user: user, status: :reading, target_pages: 100, total_pages: 100)

      expect(user.completed_pages_total).to eq(350)
    end

    it '読了した本がない場合は0を返す' do
      expect(user.completed_pages_total).to eq(0)
    end
  end

  describe '#consecutive_reading_days' do
    let(:user) { create(:user) }

    it '今日を含む連続した日付の日数を返す' do
      create(:book, user: user).tap { |b| b.update_column(:updated_at, Date.current.beginning_of_day) }
      create(:book, user: user).tap { |b| b.update_column(:updated_at, (Date.current - 1.day).beginning_of_day) }
      create(:book, user: user).tap { |b| b.update_column(:updated_at, (Date.current - 2.days).beginning_of_day) }

      expect(user.consecutive_reading_days).to eq(3)
    end

    it '今日の記録がない場合は昨日からさかのぼる' do
      create(:book, user: user).tap { |b| b.update_column(:updated_at, (Date.current - 1.day).beginning_of_day) }
      create(:book, user: user).tap { |b| b.update_column(:updated_at, (Date.current - 2.days).beginning_of_day) }

      expect(user.consecutive_reading_days).to eq(2)
    end

    it '連続が途切れた場合は途切れた分まで集計する' do
      create(:book, user: user).tap { |b| b.update_column(:updated_at, Date.current.beginning_of_day) }
      create(:book, user: user).tap { |b| b.update_column(:updated_at, (Date.current - 2.days).beginning_of_day) }

      expect(user.consecutive_reading_days).to eq(1)
    end

    it '記録がない場合は0を返す' do
      expect(user.consecutive_reading_days).to eq(0)
    end
  end
end
