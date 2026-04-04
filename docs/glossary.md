# 用語集 (Glossary)

## ドメイン用語

### 積読（つんどく）
**読み**: つんどく  
**英語**: Tsundoku

**定義**: 本を買ったものの読まずに積み上げている状態。「積んでおく」と「読む」を組み合わせた日本語の造語。

**Yomikiriでの意味**: 本アプリが管理対象とする「未読の本」または「読みかけの本」。単なる「読みたい本リスト（ウィッシュリスト）」ではなく、**既に手元にある本**を指す。

**使用例**: 「積読を登録する」「積読が50冊たまった」

---

### 賞味期限（しょうみきげん）
**読み**: しょうみきげん  
**英語**: Best-before date / Expiration date

**定義**: 通常は食品などの品質保証期限を指すが、Yomikiriでは**本を読み終えるべき期限**のこと。

**Yomikiriでの意味**: ユーザーが設定した「読了期限（Deadline）」。技術書やビジネス書は情報が古くなる（賞味期限が切れる）ため、「いつまでに読まないと意味がない」という意識を持たせるために「賞味期限」と表現している。

**技術的表現**: `Book#deadline` (Date型)

**使用例**: 「この本の賞味期限は3日後です」「賞味期限を延長する」

---

### ノルマ（のるま）
**読み**: のるま  
**英語**: Quota / Daily reading quota

**定義**: ロシア語由来の日本語で、「割り当てられた仕事量」の意味。

**Yomikiriでの意味**: **1日あたりに読むべきページ数**。賞味期限（読了期限）と残ページ数から自動計算される。

**計算式**:
```
ノルマ = ⌈(読了対象ページ数 - 現在ページ) / 残日数⌉
```
※ 残日数は今日を含む（期限当日は残日数=1）  
※ 切り上げ（ceil）で計算

**技術的表現**: `Book#calculate_daily_quota` メソッドの戻り値

**使用例**: 「今日のノルマは46ページです」「ノルマを達成しました」

---

### 読了対象ページ数（どくりょうたいしょうぺーじすう）
**読み**: どくりょうたいしょうぺーじすう  
**英語**: Target pages

**定義**: ユーザーが「読み終えたい」と設定したページ数。

**Yomikiriでの意味**: 技術書の場合、「付録や索引を除いた本文のみ」や「特定の章だけ」など、全ページを読まないこともあるため、総ページ数とは別に設定可能。

**技術的表現**: `Book#target_pages` (Integer)

**使用例**: 「この本は300ページあるけど、付録を除いた260ページを読了対象にする」

---
### 進捗（しんちょく）
**読み**: しんちょく  
**英語**: Progress

**定義**: 現在どこまで読んだかを示す指標。現在ページを読了対象ページ数で割った割合（%）で表現される。

**計算式**: 進捗(%) = 現在ページ ÷ 読了対象ページ数 × 100

**技術的表現**: `Book#progress_percentage` メソッドの戻り値（Float）

**使用例**: 「全300ページのうち150ページ読んだので、進捗は50%」

---

### 読了（どくりょう）
**読み**: どくりょう  
**英語**: Completed

**定義**: 本を読み終えた状態。手動で切り替える。

**Yomikiriでの意味**: 現在ページが読了対象ページ数に到達時は「読了にする」ボタンを強調表示。状態は一覧から除外され、品すっきり感を与える。

**技術的表現**: `Book#status == :completed`、`complete` アクションで切り替え

**使用例**: 「読了になり一覧がスッキリした！」

---

### 書影（しょえい）
**読み**: しょえい  
**英語**: Book cover image

**定義**: 本の表紙画像。Yomikiriでは任意登録で、未設定時はプレースホルダーを表示。

**Yomikiriでの意味**: 賞味期限ビジュアライザーの表現対象。期限が迫るほど画像が色褪せる。

**技術的表現**: `Book#cover_image_url` （URL文字列、未設定時はプレースホルダーURLを返却）

**使用例**: 「書影が未設定の場合はプレースホルダーを表示する」

---

### 読書ステータス（どくしょすてーたす）
**読み**: どくしょすてーたす  
**英語**: Reading Status

**定義**: 本の現在の読書状態。未読・読書中・読了の3段階。

| 値 | 日本語 | 原因 |
|------|------|------|
| `unread` | 未読 | 登録時の初期状態 |
| `reading` | 読書中 | 進捗を更新すると自動移行 |
| `completed` | 読了 | 手動切り替え |

**技術的表現**: `Book.status` （ActiveRecord enum）

**使用例**: 「進捗を更新すると読書ステータスが自動的に『読書中』に変わる」

---
### 賞味期限ビジュアライザー（しょうみきげんびじゅあらいざー）
**読み**: しょうみきげんびじゅあらいざー  
**英語**: Expiration date visualizer

**定義**: 期限が近づくほど書影が色褪せる（セピア調 + 透明度低下）視覚エフェクト。

**Yomikiriでの意味**: 期限の緊急度を「数字」ではなく「体感」で伝える仕組み。一覧画面でひと目で「ヤバい本」が分かる。

**技術的実装**: CSS `filter: sepia()` + `opacity` の段階的適用

| 残り日数 | セピア | 透明度 | 視覚的印象 |
|---------|-------|--------|----------|
| 7日以上 | 0% | 100% | 通常（フルカラー） |
| 7日以下 | 30% | 90% | やや色褪せ |
| 3日以下 | 60% | 70% | かなり色褪せ |
| 1日以下 | 100% | 50% | ほぼセピア |
| 期限超過 | 100% | 30% | ほぼ消えかけ |
**使用例**: 「期限が3日を切ると、賞味期限ビジュアライザーが強くなる」

---

### 積読タイムライン（つんどくたいむらいん）
**読み**: つんどくたいむらいん  
**英語**: Tsundoku Timeline

**定義**: 他のユーザーの積読状況や進捗を時系列で表示する機能（本リリースで実装予定）。

**Yomikiriでの意味**: 共有設定した本のみが表示され、イベント単位（新規登録/期限3日前/読了）で他ユーザーの様子が分かる。「自分だけじゃない」という安心感と、他者の進捗による刺激で継続を支援。

**技術的実装**: `Event`モデルで管理、`is_public`フラグで公開制御

**使用例**: 「積読タイムラインで、他のユーザーが同じ本を読んでいることを知った」

---

### 期限3日前イベント（きげんみっかまえいべんと）
**読み**: きげんみっかまえいべんと  
**英語**: 3-day reminder event

**定義**: 賞味期限の3日前（JST 00:00基準）に発火するイベント。

**Yomikiriでの意味**: 同一ユーザー・同一本につき1回のみ発火。メール通知（本リリース）や積読タイムライン表示（本リリース）のトリガーとなる。

**技術的実装**: GitHub Actionsの定期実行（毎日JST 00:00）で判定・生成

**判定ロジック**:
```ruby
Date.today == book.deadline - 3.days
```

**使用例**: 「期限3日前イベントが発火し、リマインドメールが送信された」

---

## 技術用語

### MVP（Minimum Viable Product）
**読み**: エムブイピー  
**英語**: Minimum Viable Product

**定義**: 最小限の機能で動作する製品。顧客からフィードバックを得るために、まず市場に投入するバージョン。

**Yomikiriでのフェーズ定義**:
- **MVP**: 基本機能のみ（認証、CRUD、ノルマ計算、簡易カレンダー連携）
- **本リリース**: 自動カレンダー連携、ISBN検索、メール通知、積読タイムライン
- **将来**: LINE通知、OGP画像生成、読書イベント機能

**使用例**: 「MVPではGoogleカレンダー連携は簡易版（URL生成のみ）」

---

### 本リリース（ほんりりーす）
**読み**: ほんりりーす  
**英語**: Full Release / Production Release

**定義**: MVP後の正式リリース。ユーザーフィードバックを反映し、機能を拡充したバージョン。

**Yomikiriでの本リリース機能**:
- OAuth認証によるGoogleカレンダー自動挿入
- openBD APIによる書籍情報取得
- SendGridによるメール通知
- 積読タイムライン
- 読了シェア（OGP対応）

**使用例**: 「本リリースではメール通知を実装する」

---

### ユビキタス言語（ゆびきたすげんご）
**読み**: ゆびきたすげんご  
**英語**: Ubiquitous Language

**定義**: ドメイン駆動設計（DDD）における概念。開発者、ドメインエキスパート、ユーザーが共通して使用する言葉。

**Yomikiriでの適用**: 「積読」「賞味期限」「ノルマ」などの用語を、コード（モデル名、メソッド名）、UI、ドキュメントで統一して使用する。

**使用例**: 「`deadline`ではなく`expiration_date`と呼ぶべきか？→ 日本語UIでは『賞味期限』だが、技術的には『deadline』が分かりやすいため、コードでは`deadline`を使用する」

---

### Rails標準認証（れーるずひょうじゅんにんしょう）
**読み**: れーるずひょうじゅんにんしょう  
**英語**: Rails Standard Authentication

**定義**: Ruby on Railsでユーザー認証を実装するための標準的なGem。Yomikiriでは**Devise**を使用。

**Deviseの主な機能**:
- サインアップ / ログイン / ログアウト
- パスワードハッシュ化（bcrypt）
- セッション管理（Cookie）
- パスワードリセット（本リリースでメール送信）
- Remember Me（ログイン状態を保持）

**技術的実装**: `User`モデルに`devise`を追加

**使用例**: 「Deviseでユーザー認証を実装する」

---

### bcrypt（びーくりぷと）
**読み**: びーくりぷと  
**英語**: bcrypt

**定義**: パスワードをハッシュ化（暗号化）するアルゴリズム。Deviseのデフォルト。

**特徴**:
- ソルト（ランダムな値）を自動生成
- ストレッチング（繰り返し計算）でブルートフォース攻撃に強い
- コスト係数12（デフォルト）

**使用例**: 「パスワードはbcryptでハッシュ化され、平文では保存されない」

---

### GitHub Actions
**読み**: ぎっとはぶあくしょんず  
**英語**: GitHub Actions

**定義**: GitHubが提供するCI/CD（継続的インテグレーション/デリバリー）サービス。

**Yomikiriでの用途**:
1. **CI（`.github/workflows/ci.yml`）**: PRごとにRSpec・RuboCopを自動実行
2. **定期実行（`.github/workflows/daily_tasks.yml`）**: 毎日JST 00:00にノルマ再計算・通知送信

**定期実行のcron設定**:
```yaml
schedule:
  - cron: '0 15 * * *'  # UTC 15:00 = JST 00:00（+9時間）
```

**使用例**: 「GitHub Actionsで毎日深夜にノルマを再計算する」

---

### Render（れんだー）
**読み**: れんだー  
**英語**: Render

**定義**: Web アプリケーションのホスティングサービス。Herokuの代替として人気。

**Yomikiriでの採用理由**:
- 無料枠でRailsアプリをホスティング可能
- GitHubと連携し、`main`ブランチへのプッシュで自動デプロイ
- HTTPS自動対応（Let's Encrypt）
- PostgreSQLデータベースも提供（ただしYomikiriではNeonを使用）

**技術的設定**: `Procfile`で`web: bundle exec puma`を指定

**使用例**: 「Renderにデプロイすると、数分で本番環境が立ち上がる」

---

### Neon（におん）
**読み**: におん  
**英語**: Neon

**定義**: PostgreSQL互換のサーバーレスデータベースサービス。

**Yomikiriでの採用理由**:
- 無料枠で最大1GBまで利用可能
- 自動バックアップ（ポイントインタイムリカバリ）
- コールドスタート高速
- スケーラブル

**技術的接続**: `config/database.yml`の`production`セクションで`DATABASE_URL`環境変数を参照

**使用例**: 「NeonのPostgreSQLデータベースに接続する」

---

### Hotwire / Turbo / Stimulus
**読み**: ほっとわいやー / たーぼ / スティュミュラス  
**英語**: Hotwire / Turbo / Stimulus

**定義**: Rails標準のHTML-over-the-wireフレームワークグループ。JavaScriptを最小限に押さえ、サーバーコンポーネントでUI更新を実現する。

| ライブラリ | 機能 |
|-----------|------|
| Turbo Drive | ページ遷移のSPA化（全体リロード不要） |
| Turbo Frames | ページの一部だけ更新 |
| Turbo Streams | WebSocket / SSE でHTMLをプッシュ |
| Stimulus | 軽量JavaScriptコントローラー |

**Yomikiriでの使用**: 進捗更新がスムーズに実行される（Rails 7.2 でデフォルト有効）。Stimulus コントローラーは `app/javascript/controllers/` に配置。

**使用例**: 「Stimulusコントローラーで進捗バーをリアルタイム更新する」

---

### RSpec（あーるすぺっく）
**読み**: あーるすぺっく  
**英語**: RSpec

**定義**: Ruby向けのBDD（振る舞い駆動開発）テストフレームワーク。

**Yomikiriでのテスト種別**:
1. **Model Specs**: ビジネスロジックのテスト（カバレッジ90%以上）
2. **Request Specs**: コントローラーのHTTPレスポンステスト
3. **System Specs**: E2Eテスト（Capybara使用）

**基本構文**:
```ruby
describe Book do
  it 'ノルマを計算できる' do
    book = Book.new(target_pages: 300, current_page: 119, deadline: 3.days.from_now.to_date)
    expect(book.calculate_daily_quota).to eq(46)
  end
end
```

**使用例**: 「RSpecでBook#calculate_daily_quotaのテストを書く」

---

### RuboCop（るぼこっぷ）
**読み**: るぼこっぷ  
**英語**: RuboCop

**定義**: Rubyの静的解析ツール（Linter）。コードスタイルを自動チェック。

**Yomikiriでの設定**: `.rubocop.yml`でルールをカスタマイズ
- インデント: 2スペース
- 文字列: シングルクォート優先
- メソッド長: 15行以内

**実行コマンド**:
```bash
bundle exec rubocop               # 全ファイルチェック
bundle exec rubocop -a            # 自動修正
bundle exec rubocop app/models/   # 特定ディレクトリのみ
```

**使用例**: 「RuboCopでコードスタイルをチェックし、違反を修正する」

---

### N+1クエリ問題（えぬぷらすわんくえりもんだい）
**読み**: えぬぷらすわんくえりもんだい  
**英語**: N+1 Query Problem

**定義**: 関連データを取得する際、親レコード1件につき子レコード取得クエリが1回発行され、合計N+1回のクエリが実行される問題。

**問題例**:
```ruby
# ❌ Bad: 100冊の本があると、101回のクエリが発行される
@books = current_user.books  # 1回
@books.each { |book| book.reading_logs.count }  # N回
```

**解決策**: `includes`で一括取得
```ruby
# ✅ Good: 2回のクエリで完了
@books = current_user.books.includes(:reading_logs)
@books.each { |book| book.reading_logs.count }
```

**使用例**: 「N+1クエリ問題を`includes`で解決する」

---

### Strong Parameters（すとろんぐぱらめーたーず）
**読み**: すとろんぐぱらめーたーず  
**英語**: Strong Parameters

**定義**: Railsのセキュリティ機能。コントローラーで受け取るパラメータをホワイトリスト形式で制限する。

**実装例**:
```ruby
def book_params
  params.require(:book).permit(:title, :author, :total_pages, :deadline)
end
```

**効果**: ユーザーが不正なパラメータ（例: `user_id`）を送信しても、`permit`に含まれていないため無視される。

**使用例**: 「Strong Parametersで`user_id`の改ざんを防ぐ」

---

### CSRF（Cross-Site Request Forgery）
**読み**: しーえすあーるえふ / くろすさいとりくえすとふぉーじぇりー  
**英語**: Cross-Site Request Forgery

**定義**: 悪意のあるサイトから、ユーザーが意図しないリクエストを送信させる攻撃。

**Railsの対策**: `protect_from_forgery with: :exception`
- フォームに自動的にトークンを埋め込む
- リクエストごとにトークンを検証
- 不正なリクエストは`ActionController::InvalidAuthenticityToken`で拒否

**使用例**: 「RailsはデフォルトでCSRF対策が有効」

---

### XSS（Cross-Site Scripting）
**読み**: くろすさいとすくりぷてぃんぐ  
**英語**: Cross-Site Scripting

**定義**: 悪意のあるスクリプトをWebページに埋め込む攻撃。

**Railsの対策**: ERBテンプレートで自動エスケープ
```erb
<!-- ✅ 自動的にHTMLエスケープされる -->
<h1><%= @book.title %></h1>
```

**注意点**: HTMLを意図的に出力する場合は`sanitize`を使用
```erb
<%= sanitize(@book.description) %>
```

**使用例**: 「ERBの`<%= %>`は自動的にXSS対策される」

---

### OAuth 2.0（おーおーす）
**読み**: おーおーす  
**英語**: OAuth 2.0

**定義**: サードパーティアプリケーションにユーザーのリソースへのアクセス権限を委譲するための認証プロトコル。

**Yomikiriでの用途**: Googleカレンダーへの自動書き込み（本リリース）
1. ユーザーがGoogleアカウントで認証
2. YomikiriがGoogleカレンダーAPIへのアクセス権限を取得
3. ユーザーの代わりにカレンダー予定を作成

**技術的実装**: `omniauth-google-oauth2` Gem使用

**使用例**: 「OAuth認証でGoogleカレンダーへの書き込み権限を取得する」

---

### openBD API（おーぷんびーでぃーえーぴーあい）
**読み**: おーぷんびーでぃーえーぴーあい  
**英語**: openBD API

**定義**: 日本の書籍情報を無料で取得できるAPI。ISBN（書籍コード）を入力すると、タイトル・著者・書影URLなどが返される。

**Yomikiriでの用途**: 本リリースで書籍登録時にISBNを入力すると、タイトルや書影を自動補完

**APIキー**: 不要（完全無料）

**エンドポイント**: `https://api.openbd.jp/v1/get?isbn={ISBN}`

**使用例**: 「openBD APIでISBNから書籍情報を取得する」

---

### SendGrid（せんどぐりっど）
**読み**: せんどぐりっど  
**英語**: SendGrid

**定義**: メール配信サービス。API経由でメールを送信できる。

**Yomikiriでの用途**: 本リリースで期限3日前のリマインドメールを送信

**無料枠**: 1日100通まで

**技術的実装**: ActionMailer + SendGrid SMTP設定

**使用例**: 「SendGridで期限前リマインドメールを送信する」

---

### GitHub Flow（ぎっとはぶふろー）
**読み**: ぎっとはぶふろー  
**英語**: GitHub Flow

**定義**: シンプルなGitワークフロー。`main`ブランチから`feature`ブランチを作成し、PR経由でマージする。

**Yomikiriのフロー**:
1. `main`から`feature/add-google-calendar`ブランチを作成
2. 実装・コミット
3. プッシュし、Pull Request作成
4. レビュー・承認
5. Squash and Mergeで`main`へマージ
6. Renderが自動デプロイ

**使用例**: 「GitHub Flowで新機能ブランチを作成し、PRでレビューを受ける」

---

### Squash and Merge（すかっしゅあんどまーじ）
**読み**: すかっしゅあんどまーじ  
**英語**: Squash and Merge

**定義**: Pull Request内の複数コミットを1つにまとめてマージする方法。

**メリット**: `main`ブランチのコミット履歴がシンプルになる

**使用例**: 「Squash and Mergeで、10個のコミットを1つにまとめて`main`へマージする」

---

## データモデル用語

### User（ゆーざー）
**英語**: User

**定義**: Yomikiriのユーザーアカウント。Deviseで管理。

**主な属性**:
- `email`: メールアドレス（ログインID）
- `encrypted_password`: 暗号化されたパスワード
- `nickname`: 表示名（積読タイムラインで使用）
- `created_at`: 登録日時

**関連**: `has_many :books`（1ユーザーは複数の本を持つ）

---

### Book（ぶっく）
**英語**: Book

**定義**: 積読本。Yomikiriの中心的なモデル。

**主な属性**:
- `title`: タイトル（必須）
- `author`: 著者
- `total_pages`: 総ページ数（必須）
- `target_pages`: 読了対象ページ数（必須）
- `current_page`: 現在ページ（デフォルト0）
- `deadline`: 賞味期限（必須）
- `status`: 読書ステータス（enum: `unread`, `reading`, `completed`）
- `extension_count`: 期限延長回数（デフォルト0）
- `completed_at`: 読了日時
- `daily_quota`: 1日あたりのノルマ（自動計算でキャッシュ）

**関連**: `belongs_to :user`, `has_many :reading_logs`

**主要メソッド**:
- `calculate_daily_quota`: ノルマを計算
- `days_until_deadline`: 残日数を計算

---

### ReadingLog（りーでぃんぐろぐ）
**英語**: Reading Log

**定義**: 読書記録。いつ何ページ読んだかを記録する。MVP段階で進捗更新時に自動作成される。

**主な属性**:
- `book_id`: 本のID（外部キー）
- `pages_read`: 読んだページ数
- `read_at`: 読んだ日時

**関連**: `belongs_to :book`

**用途**: 読書履歴の可視化、読書スピード計測（将来機能）

---

### Event（いべんと）
**英語**: Event

**定義**: 積読タイムラインに表示されるイベント（本リリースで実装）。

**主な属性**:
- `user_id`: ユーザーID
- `book_id`: 本のID
- `event_type`: イベント種別（enum: `registered`, `deadline_approaching`, `completed`）
- `is_public`: 公開フラグ（デフォルト非公開）
- `occurred_at`: 発生日時

**関連**: `belongs_to :user`, `belongs_to :book`

---

## UI/UX用語

### レスポンシブデザイン（れすぽんしぶでざいん）
**読み**: れすぽんしぶでざいん  
**英語**: Responsive Design

**定義**: デバイスの画面サイズに応じてレイアウトが変化するデザイン。

**Yomikiriでの対応**: PC・タブレット・スマートフォンで見やすいUIを提供

---

### フラッシュメッセージ（ふらっしゅめっせーじ）
**読み**: ふらっしゅめっせーじ  
**英語**: Flash Message

**定義**: 一時的な通知メッセージ。「本を登録しました」「進捗を更新しました」など。

**技術的実装**: Railsの`flash[:notice]`、`flash[:alert]`

---

### プレースホルダー（ぷれーすほるだー）
**読み**: ぷれーすほるだー  
**英語**: Placeholder

**定義**: データが未設定の場合に表示される代替コンテンツ。

**Yomikiriでの使用例**: 書影が未設定の場合、デフォルト画像（本のアイコン）を表示

---

---

## アーキテクチャ・フレームワーク用語

### MVCアーキテクチャ（えむぶぃしーあーきてくちゃ）
**読み**: えむぶぃしーあーきてくちゃ  
**英語**: Model-View-Controller Architecture

**定義**: アプリケーションをデータ・ビジネスロジック（Model）、画面表示（View）、制御（Controller）の3層に分離する設計パターン。Railsの標準構成。

**Yomikiriでの実装例**:
- **Model**: `Book`、`User`、`ReadingLog` — データベース操作とドメインロジック
- **View**: `app/views/books/*.html.erb` — HTML生成
- **Controller**: `BooksController` — リクエストを受けモデルとビューを連携

---

### サービス層（さーびすそう）
**読み**: さーびすそう  
**英語**: Service Layer

**定義**: ControllerやModelに属さない複雑なビジネスロジックを封じ込めるクラスの集合。`app/services/`ディレクトリに配置。

**Yomikiriでの使用例**:
- `DailyQuotaCalculatorService` — ノルマ再計算ロジック
- `GoogleCalendarService` — Googleカレンダー URL生成
- `OpenBdService` — ISBN APIラッパー

---

### バリデーション（ばりでーしょん）
**読み**: ばりでーしょん  
**英語**: Validation

**定義**: データがデータベースに保存される前に、内容の整合性を検証する仕組み。ActiveRecordの`validates`マクロで定義。

**Yomikiriでの内容例**:
```ruby
class Book < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :total_pages, numericality: { greater_than: 0 }
  validate :deadline_must_be_future
end
```

---

### enum（列挙型）
**読み**: いぬーむ  
**英語**: Enumeration

**定義**: 数値を具体的な名前に対応させるActiveRecordの機能。DBには整数で保存し、Rubyには意味のある名前で参照できる。

**Yomikiriでの定義**:
```ruby
class Book < ApplicationRecord
  enum :status, { unread: 0, reading: 1, completed: 2 }
end
# 使用例: book.reading? / book.reading! / Book.completed
```

---

### マイグレーション（まいぐれーしょん）
**読み**: まいぐれーしょん  
**英語**: Migration

**定義**: データベーススキーマ変更をバージョン管理するファイル群。`db/migrate/`に配置され、`rails db:migrate`で実行する。

**実際の対応**: DB変更をコードとしバージョン管理することで、チーム全員が同じDB構造を共有できる。

---

### スキーマ（すきーま）
**読み**: すきーま  
**英語**: Schema

**定義**: データベースの構造（テーブル定義・カラム型・制約）を表現したファイル。`rails db:migrate`実行後に`db/schema.rb`が自動生成される。

**注意**: `db/schema.rb`は自動生成ファイルのため直接編集しない。

---

### 外部キー（がいぶきー）
**読み**: がいぶきー  
**英語**: Foreign Key

**定義**: あるテーブルのカラムが別テーブルの主キー（`id`）を参照する制約。データ整合性をDBレベルで保証する。

**Yomikiriでの実例**: `books.user_id` → `users.id`、`reading_logs.book_id` → `books.id`

---

### スコープ（すこーぷ）
**読み**: すこーぷ  
**英語**: ActiveRecord Scope

**定義**: よく使われるクエリ条件に名前を付けて再利用可能にするActiveRecordの機能。メソッドチェーン可能。

**Yomikiriでの例**:
```ruby
class Book < ApplicationRecord
  scope :active, -> { where.not(status: :completed) }
  scope :by_deadline, -> { order(deadline: :asc) }
end
# 使用例: Book.active.by_deadline
```

---

### FactoryBot（ファクトリーボット）
**読み**: ふぁくとりーぼっと  
**英語**: FactoryBot

**定義**: テスト用のデータ作成パターン（ファクトリー）を定義するgem。`spec/factories/`に定義し、RSpec内で実験データを効率的に作成できる。

**Yomikiriでの例**:
```ruby
# spec/factories/books.rb
FactoryBot.define do
  factory :book do
    association :user
    title { 'みんなの Ruby on Rails ガイド' }
    total_pages { 400 }
    deadline { 2.weeks.from_now }
    status { :reading }
  end
end
# 使用: create(:book) / build(:book, title: "カスタムタイトル")
```

---

### Capybara（カピバラ）
**読み**: かぴばら  
**英語**: Capybara

**定義**: Rubyのブラウザシミュレーションライブラリ。RSpecのシステムスペックで用い、実際のブラウザ操作（クリック、フォーム入力等）をエミュレートする。

**Yomikiriでの例**:
```ruby
# spec/system/books_spec.rb
it '積読を登録できる' do
  visit new_book_path
  fill_in 'タイトル', with: 'リーンスタートアップ'
  click_button '登録'
  expect(page).to have_text('登録しました')
end
```

---

### OGP（おーじーぴー）
**読み**: おーじーぴー  
**英語**: Open Graph Protocol

**定義**: SNSシェア時にプレビューカード（タイトル・画像・詳細）を表示するためのHTMLメタタグ規格。Facebookが策定し、Twitterカード等も同様の仕組み。

**Yomikiriでの例**（本リリース）:
```html
<meta property="og:title" content="「Ruby」を読了しました! - Yomikiri" />
<meta property="og:description" content="14日間で読めました" />
```

---

## まとめ

この用語集は、Yomikiriプロジェクトにおける**ユビキタス言語**を定義しています。

- **ドメイン用語**: プロダクトの核となる概念（積読、賞味期限、ノルマ）
- **技術用語**: 実装で使用する技術（Rails、RSpec、OAuth）
- **データモデル用語**: データベース設計の基本（User、Book、ReadingLog）
- **UI/UX用語**: ユーザーインターフェースの要素
- **アーキテクチャ・フレームワーク用語**: MVC、サービス層、バリデーション等の設計パターン

新しいメンバーがプロジェクトに参加する際は、まずこの用語集を読むことで、
**プロダクトの世界観**と**技術的な基盤**を理解できます。

---

## 索引

### ドメイン用語
- [積読（つんどく）](#積読つんどく)
- [賞味期限（しょうみきげん）](#賞味期限しょうみきげん)
- [ノルマ（のるま）](#ノルマのるま)
- [読了対象ページ数（どくりょうたいしょうぺーじすう）](#読了対象ページ数どくりょうたいしょうぺーじすう)
- [進捗（しんちょく）](#進捗しんちょく)
- [読了（どくりょう）](#読了どくりょう)
- [書影（しょえい）](#書影しょえい)
- [読書ステータス（どくしょすてーたす）](#読書ステータスどくしょすてーたす)
- [賞味期限ビジュアライザー（しょうみきげんびじゅあらいざー）](#賞味期限ビジュアライザーしょうみきげんびじゅあらいざー)
- [積読タイムライン（つんどくたいむらいん）](#積読タイムラインつんどくたいむらいん)
- [期限3日前イベント（きげんみっかまえいべんと）](#期限3日前イベントきげんみっかまえいべんと)

### 技術用語
- [MVP（Minimum Viable Product）](#mvpminimum-viable-product)
- [本リリース（ほんりりーす）](#本リリースほんりりーす)
- [ユビキタス言語（ゆびきたすげんご）](#ユビキタス言語ゆびきたすげんご)
- [Rails標準認証（れーるずひょうじゅんにんしょう）](#rails標準認証れーるずひょうじゅんにんしょう)
- [bcrypt（びーくりぷと）](#bcryptびーくりぷと)
- [GitHub Actions](#github-actions)
- [Render（れんだー）](#renderれんだー)
- [Neon（におん）](#neonにおん)
- [Hotwire / Turbo / Stimulus](#hotwire--turbo--stimulus)
- [RSpec（あーるすぺっく）](#rspecあーるすぺっく)
- [RuboCop（るぼこっぷ）](#rubocopるぼこっぷ)
- [N+1クエリ問題（えぬぷらすわんくえりもんだい）](#n1クエリ問題えぬぷらすわんくえりもんだい)
- [Strong Parameters（すとろんぐぱらめーたーず）](#strong-parametersすとろんぐぱらめーたーず)
- [CSRF（Cross-Site Request Forgery）](#csrfcross-site-request-forgery)
- [XSS（Cross-Site Scripting）](#xsscross-site-scripting)
- [OAuth 2.0（おーおーす）](#oauth-20おーおーす)
- [openBD API（おーぷんびーでぃーえーぴーあい）](#openbd-apiおーぷんびーでぃーえーぴーあい)
- [SendGrid（せんどぐりっど）](#sendgridせんどぐりっど)
- [GitHub Flow（ぎっとはぶふろー）](#github-flowぎっとはぶふろー)
- [Squash and Merge（すかっしゅあんどまーじ）](#squash-and-mergeすかっしゅあんどまーじ)

### アーキテクチャ・フレームワーク用語
- [MVCアーキテクチャ（えむぶぃしーあーきてくちゃ）](#mvcアーキテクチャえむぶぃしーあーきてくちゃ)
- [サービス層（さーびすそう）](#サービス層さーびすそう)
- [バリデーション（ばりでーしょん）](#バリデーションばりでーしょん)
- [enum（列挙型）](#enum列挙型)
- [マイグレーション（まいぐれーしょん）](#マイグレーションまいぐれーしょん)
- [スキーマ（すきーま）](#スキーマすきーま)
- [外部キー（がいぶきー）](#外部キーがいぶきー)
- [スコープ（すこーぷ）](#スコープすこーぷ)
- [FactoryBot（ふぁくとりーぼっと）](#factorybotふぁくとりーぼっと)
- [Capybara（かぴばら）](#capybaraかぴばら)
- [OGP（おーじーぴー）](#ogpおーじーぴー)

### データモデル用語
- [User（ゆーざー）](#userゆーざー)
- [Book（ぶっく）](#bookぶっく)
- [ReadingLog（りーでぃんぐろぐ）](#readinglogりーでぃんぐろぐ)
- [Event（いべんと）](#eventいべんと)

### UI/UX用語
- [レスポンシブデザイン（れすぽんしぶでざいん）](#レスポンシブデザインれすぽんしぶでざいん)
- [フラッシュメッセージ（ふらっしゅめっせーじ）](#フラッシュメッセージふらっしゅめっせーじ)
- [プレースホルダー（ぷれーすほるだー）](#プレースホルダーぷれーすほるだー)
