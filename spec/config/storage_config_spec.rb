# frozen_string_literal: true

require 'rails_helper'
require 'active_storage/service/configurator'

RSpec.describe 'Active Storage storage config' do
  it 'production 用に Backblaze B2 の service 定義がある' do
    config_text = Rails.root.join('config/storage.yml').read

    expect(config_text).to include('backblaze:')
    expect(config_text).to include('service: S3')
    expect(config_text).to include('access_key_id: <%= ENV["B2_ACCESS_KEY_ID"] %>')
    expect(config_text).to include('secret_access_key: <%= ENV["B2_SECRET_ACCESS_KEY"] %>')
    expect(config_text).to include('region: <%= ENV["B2_REGION"] %>')
    expect(config_text).to include('bucket: <%= ENV["B2_BUCKET"] %>')
    expect(config_text).to include('endpoint: <%= ENV["B2_ENDPOINT"] %>')
    expect(config_text).to include('force_path_style: true')
  end

  it 'backblaze 設定で S3 アダプタを解決できる' do
    service_configurations = {
      backblaze: {
        service: 'S3',
        access_key_id: 'access',
        secret_access_key: 'secret',
        region: 'us-west-004',
        bucket: 'bucket-name',
        endpoint: 'https://s3.us-west-004.backblazeb2.com',
        force_path_style: true
      }
    }

    expect do
      ActiveStorage::Service::Configurator.build(:backblaze, service_configurations)
    end.not_to raise_error
  end
end
