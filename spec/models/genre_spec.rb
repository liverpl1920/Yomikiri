# frozen_string_literal: true

require "rails_helper"

RSpec.describe Genre, type: :model do
  describe "バリデーション" do
    subject(:genre) { build(:genre) }

    it "有効なファクトリを持つ" do
      expect(genre).to be_valid
    end

    context "name が空の場合" do
      it "無効である" do
        genre.name = ""
        expect(genre).to be_invalid
        expect(genre.errors[:name]).to be_present
      end
    end

    context "同一ユーザー内で name が重複する場合" do
      it "無効である" do
        user = create(:user)
        create(:genre, user: user, name: "SF")
        duplicate = build(:genre, user: user, name: "SF")
        expect(duplicate).to be_invalid
        expect(duplicate.errors[:name]).to be_present
      end
    end

    context "異なるユーザーで同じ name の場合" do
      it "有効である" do
        create(:genre, name: "SF")
        another = build(:genre, name: "SF")
        expect(another).to be_valid
      end
    end

    context "ユーザーのジャンルが50件に達している場合" do
      it "新規追加で無効である" do
        user = create(:user)
        user.genres.destroy_all
        create_list(:genre, 50, user: user)
        new_genre = build(:genre, user: user, name: "超過ジャンル")
        expect(new_genre).to be_invalid
        expect(new_genre.errors[:base]).to be_present
      end
    end

    context "ユーザーのジャンルが49件の場合" do
      it "新規追加で有効である" do
        user = create(:user)
        user.genres.destroy_all
        create_list(:genre, 49, user: user)
        new_genre = build(:genre, user: user, name: "追加ジャンル")
        expect(new_genre).to be_valid
      end
    end
  end

  describe "アソシエーション" do
    it { is_expected.to belong_to(:user) }
  end
end
