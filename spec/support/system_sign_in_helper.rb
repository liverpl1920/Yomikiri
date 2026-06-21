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
    expect(page).to have_current_path(dashboard_path)
  end

  # rack_test 向けの高速ログイン（Warden::Test::Helpers を経由）
  def rack_test_sign_in(user)
    Warden.test_mode!
    login_as(user, scope: :user)
  end

  # eagerLoadControllersFrom は dynamic import() を使うため非同期。
  # クリック前にこのメソッドで Stimulus コントローラーの接続を待つ。
  # identifier を指定すると特定コントローラーが接続されるまで待機する（最大 15 秒）。
  def wait_for_stimulus(identifier: nil)
    connected = false
    start = Time.now
    timeout = 15
    js_check = if identifier
                 "window.Stimulus && (() => { " \
                 "  const el = document.querySelector('[data-controller~=\"#{identifier}\"]');" \
                 "  if (!el) return false;" \
                 "  try { return !!window.Stimulus.getControllerForElementAndIdentifier(el, '#{identifier}'); } " \
                 "  catch (e) { return false; }" \
                 "})()"
    else
                 "window.Stimulus && window.Stimulus.controllers.length > 0"
    end
    until Time.now - start > timeout
      if page.evaluate_script(js_check)
        connected = true
        break
      end
      sleep 0.1
    end
    label = identifier ? "Stimulus '#{identifier}' controller" : 'Stimulus controllers'
    expect(connected).to be(true), "#{label} did not connect within #{timeout} seconds"
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
