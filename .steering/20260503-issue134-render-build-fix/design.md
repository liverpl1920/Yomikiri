# 設計書

## アーキテクチャ概要

Rails標準の環境設定レイヤーである`config/environments/production.rb`のみを最小変更する。`SENDGRID_API_KEY`未設定時のログ出力を、logger初期化順序に依存しない方法へ置き換える。

```text
production.rb
	├─ config.logger (初期化)
	├─ sendgrid_api_key 判定
	│   ├─ present? : SMTP設定
	│   └─ blank?   : perform_deliveries=false + 安全な警告出力
	└─ 以降の環境設定
```

## コンポーネント設計

### 1. production環境設定 (`config/environments/production.rb`)

責務:
- 本番時のActionMailer/SMTP設定を管理
- 環境変数未設定時の安全なフォールバックを提供

実装の要点:
- `Rails.logger.warn`は初期化順序依存があるため使用しない
- `warn`（Kernel）による標準エラー出力を用い、起動失敗を防ぐ

### 2. 検証コマンド

責務:
- 既知の再現手順で回帰を検証
- 既存テスト・lintで副作用を確認

実装の要点:
- Issue記載コマンドをそのまま実行
- プロジェクト規約に従い`bundle exec rspec`と`bundle exec rubocop`を実行

## データフロー

### SENDGRID_API_KEY 未設定時
```text
1. production.rb読み込み
2. sendgrid_api_keyがblank
3. action_mailer.perform_deliveries=false
4. warnで警告出力
5. 起動継続 -> assets:precompile成功
```

## エラーハンドリング戦略

### エラーハンドリングパターン

- loggerオブジェクトへの依存を避け、初期化前でも使える出力関数を利用する
- フェイルセーフとしてメール配信のみ無効化し、アプリ全体は停止させない

## テスト戦略

### ユニット/静的検証
- `bundle exec rspec`
- `bundle exec rubocop`

### 統合検証
- `unset RAILS_MASTER_KEY && SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile`

## 依存ライブラリ

新規追加なし。

## ディレクトリ構造

```text
変更:
- config/environments/production.rb

作業記録:
- .steering/20260503-issue134-render-build-fix/requirements.md
- .steering/20260503-issue134-render-build-fix/design.md
- .steering/20260503-issue134-render-build-fix/tasklist.md
```

## 実装の順序

1. production.rbの警告出力を安全化
2. 再現コマンドでビルド成功を確認
3. RSpec/RuboCopで回帰確認

## セキュリティ考慮事項

- APIキー未設定時にキー値をログ出力しない
- 警告文は設定不足のみを示し、機密情報は含めない

## パフォーマンス考慮事項

- 条件分岐1箇所の変更のみで、実行性能への影響は軽微

## 将来の拡張性

- 将来`config.after_initialize`でアプリロガーに統一する際も、今回の変更は安全側に動作する
