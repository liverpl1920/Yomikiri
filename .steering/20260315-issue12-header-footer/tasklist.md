# Issue #12: タスクリスト

## フェーズ1: Devise セットアップ

- [x] feature ブランチを作成する（`feature/12-header-footer`）
- [x] Devise をインストールする（`rails generate devise:install`）
- [x] User モデルを生成する（`rails generate devise User`）
- [x] nickname カラムの追加マイグレーションを作成・実行する
- [x] `config/routes.rb` に `devise_for :users` を追加する（Devise 生成時に自動追加済み）
- [x] `config/application.rb` にデフォルトの URL オプションを設定する（development.rb に設定済み）

## フェーズ2: 共通パーシャルの作成

- [x] `app/views/shared/` ディレクトリを作成する
- [x] `app/views/shared/_header.html.erb` を作成する（ゲスト・ユーザー両対応）
- [x] `app/views/shared/_footer.html.erb` を作成する

## フェーズ3: ドロップダウン（Stimulus）の実装

- [x] `app/javascript/controllers/dropdown_controller.js` を作成する

## フェーズ4: レイアウトの更新

- [x] `app/views/layouts/application.html.erb` にヘッダー・フッターを組み込む
- [x] `app/views/top/index.html.erb` から埋め込みヘッダー・フッターを削除する

## フェーズ5: CSS の追加

- [x] `app/assets/stylesheets/` に `header_footer.css` を作成し、共通ヘッダー・フッター用スタイルを定義する

## フェーズ6: テストの作成

- [x] `spec/requests/header_footer_spec.rb` を作成する（未ログイン・ログイン時のヘッダー切り替えをテスト）

## フェーズ7: 品質確認

- [x] RuboCop を実行してコードスタイルを確認する
- [x] RSpec を実行してテストがパスすることを確認する（12 examples, 0 failures）
- [x] 動作確認（ローカルサーバーを起動して画面を確認）

## 申し送り事項

（実装完了後に記載）
