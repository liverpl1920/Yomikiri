# frozen_string_literal: true

# System spec 用のログインヘルパー
#
# - rack_test（非 JS）: Warden::Test::Helpers の login_as を使ったメモリ内ログイン
# - headless_chrome（js: true）: フォーム経由でのセッション Cookie ログイン
#
# 注意: Warden.test_mode! は rack_test 専用。Selenium（js: true）では
# 実際のセッション Cookie を使うため test_mode は有効にしない。

module SystemSpecSignInHelper
  # フォーム経由でログイン（SeleniumなどJSテスト専用）
  def sign_in_via_form(user, password: 'password123')
    visit new_user_session_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: password
    click_button 'ログインする'
    expect(page).to have_current_path(books_path)
  end

  # rack_test 向けの高速ログイン（Warden::Test::Helpers を経由）
  def rack_test_sign_in(user)
    Warden.test_mode!
    login_as(user, scope: :user)
  end

  # eagerLoadControllersFrom は dynamic import() を使うため非同期。
  # クリック前にこのメソッドで Stimulus コントローラーの接続を待つ。
  # 任意の Stimulus コントローラーが接続されるまで最大 10 秒待機する。
  def wait_for_stimulus
    start = Time.now
    until Time.now - start > 10
      break if page.evaluate_script("window.Stimulus && window.Stimulus.controllers.length > 0")
      sleep 0.1
    end
    # Selenium の CDP クリックの前に JS を追加実行してブラウザ状態を同期させる
    page.evaluate_script("window.Stimulus.controllers.length")
    page.evaluate_script("window.Stimulus.controllers.length")
  end
end

# Warden::Test::Helpers を直接 include せず、必要なメソッドのみ取り込む
RSpec.configure do |config|
  config.include SystemSpecSignInHelper, type: :system
  config.include Warden::Test::Helpers, type: :system

  # JS テストでは test_mode を無効化（session Cookie ベースの認証を使うため）
  config.before(:each, type: :system, js: true) do
    # Warden::Test::Helpers の include 時に呼ばれた test_mode! を逆転させる
    Warden.instance_variable_set(:@test_mode, false)
  end

  config.after(:each, type: :system) do
    Warden.test_reset!
    # test_mode を元に戻す
    Warden.instance_variable_set(:@test_mode, false)
  end
end
