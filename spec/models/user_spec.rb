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

    it '年間目標がない場合は無効' do
      expect(build(:user, yearly_goal: nil)).not_to be_valid
    end

    it '年間目標が0以下の場合は無効' do
      expect(build(:user, yearly_goal: 0)).not_to be_valid
      expect(build(:user, yearly_goal: -1)).not_to be_valid
    end

    it '年間目標が小数の場合は無効' do
      expect(build(:user, yearly_goal: 1.5)).not_to be_valid
    end

    it '年間目標が1以上の整数の場合は有効' do
      expect(build(:user, yearly_goal: 1)).to be_valid
      expect(build(:user, yearly_goal: 100)).to be_valid
    end
  end

  describe 'アソシエーション' do
    it { is_expected.to have_many(:books).dependent(:destroy) }
    it { is_expected.to have_many(:reading_logs).through(:books) }
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

    it '読了した本の pages 合計を返す' do
      create(:book, user: user, status: :completed, pages: 200)
      create(:book, user: user, status: :completed, pages: 150)
      create(:book, user: user, status: :reading, pages: 100)

      expect(user.completed_pages_total).to eq(350)
    end

    it '読了した本がない場合は0を返す' do
      expect(user.completed_pages_total).to eq(0)
    end
  end

  describe '#consecutive_reading_days' do
    let(:user) { create(:user) }
    let(:book) { create(:book, user: user) }

    it '今日を含む連続した日付の日数を返す' do
      create(:reading_log, book: book, read_at: Date.current)
      create(:reading_log, book: book, read_at: Date.current - 1.day)
      create(:reading_log, book: book, read_at: Date.current - 2.days)

      expect(user.consecutive_reading_days).to eq(3)
    end

    it '今日の記録がない場合は昨日からさかのぼる' do
      create(:reading_log, book: book, read_at: Date.current - 1.day)
      create(:reading_log, book: book, read_at: Date.current - 2.days)

      expect(user.consecutive_reading_days).to eq(2)
    end

    it '連続が途切れた場合は途切れた分まで集計する' do
      create(:reading_log, book: book, read_at: Date.current)
      create(:reading_log, book: book, read_at: Date.current - 2.days)

      expect(user.consecutive_reading_days).to eq(1)
    end

    it '記録がない場合は0を返す' do
      expect(user.consecutive_reading_days).to eq(0)
    end
  end

  describe 'コールバック' do
    describe '#prepare_default_genres' do
      it 'ユーザー作成時にデフォルトジャンルが7つ自動登録されること' do
        user = create(:user)
        expect(user.genres.count).to eq(7)
        expect(user.genres.pluck(:name)).to match_array(User::DEFAULT_GENRES)
      end
    end
  end
end
