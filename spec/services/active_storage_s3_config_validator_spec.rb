# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveStorageS3ConfigValidator do
  let(:valid_env) do
    {
      'B2_ACCESS_KEY_ID' => 'access',
      'B2_SECRET_ACCESS_KEY' => 'secret',
      'B2_REGION' => 'us-west-004',
      'B2_BUCKET' => 'bucket-name',
      'B2_ENDPOINT' => 'https://s3.us-west-004.backblazeb2.com'
    }
  end

  describe '.missing_keys' do
    it '必須キーが揃っている場合は空配列を返す' do
      expect(described_class.missing_keys(valid_env)).to eq([])
    end

    it '不足しているキーを返す' do
      env = valid_env.merge('B2_REGION' => '', 'B2_ENDPOINT' => nil)

      expect(described_class.missing_keys(env)).to contain_exactly('B2_REGION', 'B2_ENDPOINT')
    end
  end

  describe '.assert!' do
    it '必須キーが揃っている場合は例外を発生させない' do
      expect { described_class.assert!(valid_env) }.not_to raise_error
    end

    it '不足キーがある場合は KeyError を発生させる' do
      env = valid_env.merge('B2_ACCESS_KEY_ID' => nil)

      expect { described_class.assert!(env) }
        .to raise_error(KeyError, /Missing required Active Storage B2 env vars: B2_ACCESS_KEY_ID/)
    end
  end
end
