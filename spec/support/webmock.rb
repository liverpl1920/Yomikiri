# frozen_string_literal: true

# WebMock はデフォルトで全ての外部HTTPリクエストをブロックする。
# Capybara (headless_chrome) がローカルサーバーに接続できるよう localhost を許可する。
WebMock.disable_net_connect!(allow_localhost: true)
