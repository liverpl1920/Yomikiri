# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'production Active Storage config' do
  it 'production 設定で validator が呼ばれ、サービスが :amazon に固定されている' do
    config_text = Rails.root.join('config/environments/production.rb').read

    expect(config_text).to include('ActiveStorageS3ConfigValidator.assert!')
    expect(config_text).to include('config.active_storage.service = :amazon')
    expect(config_text).not_to include(':local')
  end
end
