# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveStorageS3ConfigValidator do
  let(:valid_env) do
    {
      'AWS_ACCESS_KEY_ID' => 'access',
      'AWS_SECRET_ACCESS_KEY' => 'secret',
      'AWS_REGION' => 'ap-northeast-1',
      'AWS_S3_BUCKET' => 'bucket-name'
    }
  end

  describe '.missing_keys' do
    it '必須キーが揃っている場合は空配列を返す' do
      expect(described_class.missing_keys(valid_env)).to eq([])
    end

    it '不足しているキーを返す' do
      env = valid_env.merge('AWS_REGION' => '', 'AWS_S3_BUCKET' => nil)

      expect(described_class.missing_keys(env)).to contain_exactly('AWS_REGION', 'AWS_S3_BUCKET')
    end
  end

  describe '.assert!' do
    it '必須キーが揃っている場合は例外を発生させない' do
      expect { described_class.assert!(valid_env) }.not_to raise_error
    end

    it '不足キーがある場合は KeyError を発生させる' do
      env = valid_env.merge('AWS_ACCESS_KEY_ID' => nil)

      expect { described_class.assert!(env) }
        .to raise_error(KeyError, /Missing required Active Storage S3 env vars: AWS_ACCESS_KEY_ID/)
    end
  end
end
