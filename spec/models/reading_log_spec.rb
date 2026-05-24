require 'rails_helper'

RSpec.describe ReadingLog, type: :model do
  describe 'ファクトリ' do
    it '有効なファクトリを持つ' do
      expect(build(:reading_log)).to be_valid
    end
  end

  describe 'バリデーション' do
    it 'pages_read が 1 以上で有効' do
      expect(build(:reading_log, pages_read: 1)).to be_valid
    end

    it 'pages_read が 0 の場合は無効' do
      expect(build(:reading_log, pages_read: 0)).not_to be_valid
    end

    it 'read_at がない場合は無効' do
      expect(build(:reading_log, read_at: nil)).not_to be_valid
    end

    it 'start_page と end_page が nil の場合は有効' do
      expect(build(:reading_log, start_page: nil, end_page: nil)).to be_valid
    end

    it 'start_page が 0 以上で有効' do
      expect(build(:reading_log, start_page: 0, end_page: 10)).to be_valid
    end

    it 'start_page が負の場合は無効' do
      expect(build(:reading_log, start_page: -1)).not_to be_valid
    end

    it 'end_page が 0 の場合は無効' do
      expect(build(:reading_log, end_page: 0)).not_to be_valid
    end
  end
end
