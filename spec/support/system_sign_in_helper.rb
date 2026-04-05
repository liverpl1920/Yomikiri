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
    connected = false
    start = Time.now
    until Time.now - start > 10
      if page.evaluate_script("window.Stimulus && window.Stimulus.controllers.length > 0")
        connected = true
        break
      end
      sleep 0.1
    end
    expect(connected).to be(true), 'Stimulus controllers did not connect within 10 seconds'
  end
end

RSpec.configure do |config|
  config.include SystemSpecSignInHelper, type: :system
  # include 時に Warden.test_mode! が自動的に呼ばれ、login_as が有効になる
  config.include Warden::Test::Helpers, type: :system

  # 各テスト終了後にキューをクリアし、次のテストへの副作用を防ぐ
  config.after(:each, type: :system) do
    Warden.test_reset!
  end
end
