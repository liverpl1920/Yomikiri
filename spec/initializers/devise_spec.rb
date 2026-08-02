require 'rails_helper'

RSpec.describe 'Devise mailer sender initializer' do
  describe 'Devise.mailer_sender' do
    let(:original_mailer_sender) { Devise.mailer_sender }

    after do
      # テスト実行後に元の設定に戻す
      Devise.mailer_sender = original_mailer_sender
    end

    context '環境変数 MAILER_SENDER が設定されていない場合' do
      before do
        stub_const('ENV', ENV.to_h.except('MAILER_SENDER'))
      end

      it 'デフォルト値が noreply@yomikiri-app.com になること' do
        load Rails.root.join('config/initializers/devise.rb')
        expect(Devise.mailer_sender).to eq('noreply@yomikiri-app.com')
      end
    end

    context '環境変数 MAILER_SENDER が設定されている場合' do
      before do
        stub_const('ENV', ENV.to_h.merge('MAILER_SENDER' => 'custom-sender@example.com'))
      end

      it '環境変数の値が設定されること' do
        load Rails.root.join('config/initializers/devise.rb')
        expect(Devise.mailer_sender).to eq('custom-sender@example.com')
      end
    end
  end
end
