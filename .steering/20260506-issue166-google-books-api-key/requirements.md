# Requirements: Issue #166 Google Books API キー設定

## 概要
タイトル検索時に発生する「検索リクエストが制限されています」エラーを、
Google Books API キーの設定によって解消する。

## 背景
- APIキーなしで Google Books API を呼び出しているため、無認証クォータ（数十〜100クエリ/日/IP）に達すると HTTP 429 が返される
- `fetch_title_json` が 429 を受け取り `GoogleBooksApiError` をフロントに伝えている
- APIキーを付けることで 1,000 クエリ/日（無料枠）に拡大できる
- ユーザーから楽天ブックス APIキーも提供されたため、合わせて設定対象に含める

## 対象 Issue
- #166: [Fix] Google Books API キーを設定してタイトル検索の429エラーを解消する

## 変更対象ファイル
- `app/controllers/books_controller.rb` — `search_by_title` に `key:` パラメータ追加
- `.env.example` — `GOOGLE_BOOKS_API_KEY`, `RAKUTEN_APPLICATION_ID` のプレースホルダー追加
- `render.yaml` — 両キーのエントリを `sync: false` で追加
- `spec/requests/books_search_spec.rb` — APIキーありのケースをテスト追加（任意）

## 受け入れ条件
- [ ] `GOOGLE_BOOKS_API_KEY` 環境変数が設定されている状態でタイトル検索が正常に動作する
- [ ] キーが未設定でも既存の動作（キーなし呼び出し）が維持される
- [ ] `.env.example` に `GOOGLE_BOOKS_API_KEY`・`RAKUTEN_APPLICATION_ID` のプレースホルダーが追加されている
- [ ] `render.yaml` に両キーのエントリが追加されている
- [ ] RSpec / RuboCop が全通過する
