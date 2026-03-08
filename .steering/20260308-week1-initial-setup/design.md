# 設計: Week1 初期セットアップ

## 技術スタック（確定版）

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| フレームワーク | Ruby on Rails | 7.2.x |
| 言語 | Ruby | 3.2.x |
| データベース | PostgreSQL（Neon） | 16.x |
| CSS | Plain CSS（BEM命名規則、Tailwind不使用） |
| JS | Hotwire（Turbo+Stimulus）、デフォルト |
| テスト | RSpec 3.12.x |
| Linter | rubocop-rails-omakase |
| デプロイ | Render（Git push → 自動デプロイ） |

## ディレクトリ配置（作成するファイル）

```
Yomikiri/
├── .ruby-version                    # 3.2.x
├── .rubocop.yml                     # rubocop 設定
├── .env.example                     # 環境変数テンプレート
├── Gemfile                          # gem 定義
├── Procfile                         # Render/Heroku用コマンド
├── render.yaml                      # Render IaC 定義
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       ├── application.css      # 共通スタイル（BEM）
│   │       └── top.css              # TOPページスタイル
│   ├── controllers/
│   │   └── top_controller.rb        # TOPページコントローラー
│   └── views/
│       ├── layouts/
│       │   └── application.html.erb # 共通レイアウト
│       └── top/
│           └── index.html.erb       # TOPページビュー
├── config/
│   ├── database.yml                 # DB接続設定（Neon対応）
│   └── routes.rb                    # root route設定
├── spec/
│   ├── spec_helper.rb               # SimpleCov設定
│   └── rails_helper.rb              # RSpec Rails設定
└── .github/
    ├── pull_request_template.md     # PRテンプレート
    └── workflows/
        ├── ci.yml                   # CI パイプライン
        └── project-automation.yml  # Projects自動化
```

## 実装方針

### Rails new
```bash
rails new Yomikiri_app --database=postgresql --asset-pipeline=sprockets --skip-javascript
# ただし Hotwire はデフォルトで含む（Rails 7.2デフォルト）
```

**注意**: プロジェクトルートは `/home/ippei/runteq/graduation_work/Yomikiri/` であり、
Rails アプリのファイルはこのディレクトリ直下に展開する（rails newは別ディレクトリで実行してからmoveする）

### ルーティング
```ruby
# config/routes.rb
root "top#index"
```

### CSS設計
- BEM命名規則を採用（architecture.md準拠）
- Tailwind不使用
- `app/assets/stylesheets/` にファイル分割
- TOPページ: `.top-hero`, `.top-features`, `.top-cta` 等のBEMブロック

### RuboCopの設定
```yaml
# .rubocop.yml
inherit_gem:
  rubocop-rails-omakase: rubocop.yml
```

### SimpleCov設定（CI用カバレッジ計測）
```ruby
# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  minimum_coverage 80  # CI強制最低ライン
end
```

### CI設計
- トリガー: PR作成・push
- ジョブ: RuboCop / Brakeman / bundler-audit / RSpec（独立した4ジョブ）
- PostgreSQL: `postgres:16` サービスコンテナ
- concurrency: 同一ブランチの重複実行をキャンセル
- Artifact: テスト結果（junit XML形式）とカバレッジをアップロード
