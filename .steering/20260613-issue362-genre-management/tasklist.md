# タスクリスト: Issue #362 ジャンル管理機能

## 🚨 タスク完全完了の原則

全タスクが `[x]` になるまで作業を継続すること。

---

## フェーズ1: ブランチ・データ層

- [x] `git checkout main && git pull origin main`
- [x] `git checkout -b feature/#362-genre-management`
- [x] マイグレーション `create_genres` を作成・実行
- [x] `Genre` モデルを作成（バリデーション含む）
- [x] `User` モデルに `has_many :genres` を追加
- [x] `spec/factories/genres.rb` を作成

## フェーズ2: コントローラ・ルーティング

- [x] `config/routes.rb` にジャンル用ルーティングを追加
- [x] `GenresController` を作成（create / update / destroy）

## フェーズ3: ビュー

- [x] `genres/_genre.html.erb` を作成（1件表示）
- [x] `genres/_genre_form.html.erb` を作成（追加フォーム）
- [x] `genres/create.turbo_stream.erb` を作成
- [x] `genres/update.turbo_stream.erb` を作成
- [x] `genres/destroy.turbo_stream.erb` を作成
- [x] `mypages/show.html.erb` にジャンル設定カードを追加
- [x] `books/_form.html.erb` に `<datalist>` を追加（ユーザージャンル候補）
- [x] `mypages.css` にジャンル管理セクション用CSSを追加

## フェーズ4: テスト

- [x] `spec/models/genre_spec.rb` を作成
- [x] `spec/requests/genres_spec.rb` を作成
- [x] `spec/requests/mypages_spec.rb` にジャンル表示テストを追加

## フェーズ5: 品質チェック

- [x] `bundle exec rspec` が全件 PASS
- [x] `bundle exec rubocop` がエラーなし

## フェーズ6: コミット・PR

- [x] `git add . && git commit -m "#362 ジャンル管理機能をマイページに追加"`
- [x] `git push origin feature/#362-genre-management`
- [x] `gh pr create` で PR 作成

---

## 実装後の振り返り

### 実装完了日
2026年6月13日

### 計画と実績の差分
計画通りすべて実装が完了しました。Turbo Streamレスポンスのエラーハンドリングにおいて、エラー発生時にも適切にフォームを置き換えエラーメッセージを表示できるよう修正を行いました。また、他ユーザーのリソースへのアクセス制御や未ログインアクセス時のリダイレクト制御などもリクエストスペックで確認し、堅牢な実装を行いました。
