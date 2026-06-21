# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'genres:setup_defaults' do
  before(:all) do
    unless Rake::Task.task_defined?('genres:setup_defaults')
      Rails.application.load_tasks
    end
  end

  before(:each) do
    Rake::Task['genres:setup_defaults'].reenable
  end

  let!(:user) { create(:user) }

  it '既存ユーザーにデフォルトジャンルが作成されること' do
    # ユーザー新規作成時のコールバックで自動作成されたジャンルを一旦クリアして既存ユーザーを模倣
    user.genres.destroy_all

    expect {
      Rake::Task['genres:setup_defaults'].invoke
    }.to change(Genre, :count).by(7)

    user.reload
    expect(user.genres.pluck(:name)).to match_array(User::DEFAULT_GENRES)
  end

  it 'すでに登録済みのジャンルは重複登録されないこと' do
    user.genres.destroy_all
    user.genres.create!(name: 'ビジネス')
    user.genres.create!(name: 'オリジナルジャンル')

    expect {
      Rake::Task['genres:setup_defaults'].invoke
    }.to change(Genre, :count).by(6)

    user.reload
    expect(user.genres.pluck(:name)).to include(*User::DEFAULT_GENRES)
    expect(user.genres.pluck(:name)).to include('オリジナルジャンル')
  end
end
