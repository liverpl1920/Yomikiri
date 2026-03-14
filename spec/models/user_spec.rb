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
end
