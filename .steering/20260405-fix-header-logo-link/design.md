# 設計書

## アーキテクチャ概要

Rails の View テンプレートで Devise の `user_signed_in?` ヘルパーを使い、
ロゴリンクの href をログイン状態に応じて三項演算子で切り替える。

```
_header.html.erb
  └─ link_to 'Yomikiri', (user_signed_in? ? books_path : root_path), ...
```

## コンポーネント設計

### 1. `app/views/shared/_header.html.erb`

**責務**:
- ヘッダー全体のレンダリング
- ロゴリンクの href をログイン状態に応じて切り替える

**実装の要点**:
- `user_signed_in?` は Devise が提供するビューヘルパー（既存コードでも使用済み）
- 変更箇所は1行のみ（`root_path` → `user_signed_in? ? books_path : root_path`）
- CSS クラス `site-header__logo` は変更しない

## データフロー

### ロゴクリック時の遷移
```
1. ユーザーがヘッダーロゴをクリック
2. user_signed_in? を評価
3a. true  → /books へ遷移 (BooksController#index)
3b. false → /    へ遷移 (TopController#index)
```

## エラーハンドリング戦略

ビューヘルパーの変更のみのため、専用エラーハンドリングは不要。

## テスト戦略

### リクエストスペック（`spec/requests/header_footer_spec.rb`）

既存の `spec/requests/header_footer_spec.rb` にヘッダーロゴリンクの検証を追加する。

- **ログイン済みの場合**: ロゴリンクの href が `books_path` であること
- **未ログインの場合**: ロゴリンクの href が `root_path` であること
