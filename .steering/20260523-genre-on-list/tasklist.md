# タスクリスト: 一覧画面にジャンル情報を表示する

## フェーズ1: 実装

- [x] index.html.erb にジャンルタグを追加する
- [x] books.css に `.book-card__genre` スタイルを追加する
- [x] ジャンル表示のシステムスペックを追加する

## フェーズ2: 検証

- [x] RSpec を実行し全テストが通過することを確認する
- [x] RuboCop を実行しエラーがないことを確認する

---

## 実装後の振り返り

**実装完了日:** 2026-05-23

**計画と実績の差分:**
- 計画通りに3ファイル（index.html.erb, books.css, genre_display_spec.rb）を変更
- isbn_autofetch_spec の flaky test（fill_in のIMEタイミング問題）を合わせて修正
- CSSの `font-size` を設計書の 0.75rem に統一し、`color` を CSS カスタムプロパティ（`var(--color-text-muted)`）に変更（Copilotレビュー指摘を反映）

**学んだこと:**
- CI 環境では日本語 `fill_in` がIMEタイミング問題で失敗するため、`page.execute_script` で値をセットするパターンが安全
- CSS で色を定義する際はカスタムプロパティを優先すると、テーマ変更時の保守性が高まる

**次回への改善提案:**
- 新しい CSS クラスを追加する際は、既存のカスタムプロパティ（`--color-text-muted` など）を積極的に使うことを設計書に明記する
- system spec で日本語テキストを入力する場合は `page.execute_script` を使う規約をガイドラインに追加する
