# タスクリスト (Issue #324)

## 作業計画

- [x] 1. 作業の準備
  - [x] 1-1. 新しいブランチ `feature/#324-dashboard-lookback-cover` を作成する
- [x] 2. テストの作成・修正
  - [x] 2-1. `spec/system/dashboards_spec.rb` に書影表示のテストを追加する（画像ありの場合と画像なしの場合でそれぞれ表示されていることを確認するテスト）
- [x] 3. 実装
  - [x] 3-1. ビュー `app/views/dashboards/_random_lookback.html.erb` を修正して、書影のHTML構造を追加する
  - [x] 3-2. スタイル `app/assets/stylesheets/dashboards.css` を修正し、Flexboxによるレイアウトとレスポンシブ対応、プレースホルダーのスタイルを追加する
- [x] 4. 検証と調整
  - [x] 4-1. システムテストを実行し、テストがパスすることを確認する (`bundle exec rspec spec/system/dashboards_spec.rb`)
  - [x] 4-2. RuboCop を実行し、規約違反がないことを確認する (`bundle exec rubocop`)
- [/] 5. PR作成と振り返り
  - [/] 5-1. コミット & プッシュ & PR作成を行う
  - [/] 5-2. `tasklist.md` に振り返りを追記する
