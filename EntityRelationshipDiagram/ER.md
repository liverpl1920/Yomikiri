# Yomikiri ER図解説

## 本サービスの概要（700文字以内）

Yomikiriは、技術書やビジネス書の「積読（つんどく）」に悩む人のための読書管理アプリです。

**課題：** エンジニアや自己研鑽に励むビジネスパーソンは、良書を次々と購入するものの、「読みたい気持ちはあるのに時間が作れない」という悩みを抱えがちです。既存の読書管理アプリは「記録」が中心で、「読ませる」ための仕組みが不足しています。

**解決策：** 本サービスは、本に「賞味期限（読了期限）」を設定し、期限から逆算した「今日のノルマ（必要ページ数）」を提示することで、読書を具体的な行動に変換します。さらに、Googleカレンダー連携により読書時間を予定として確保し、「いつ読むか」を明確にします。

**主な機能：** 積読登録（タイトル・総ページ数・読了期限の設定）、ノルマ計算（残ページ数÷残日数で1日の必要読書量を自動算出）、賞味期限ビジュアライザー（期限が近づくと書影が色褪せ、緊急度を視覚化）、Googleカレンダー連携（ワンクリックで読書予定を作成）。

**想定ユーザー：** プログラミング初学者・現役エンジニア、資格試験に励むビジネスパーソン、積読に罪悪感を感じている読書家。

---

## MVPで実装する予定の機能

- 会員登録・ログイン機能（Devise認証）
- 積読一覧表示機能（期限が近い順にソート）
- 積読登録機能（書影は任意、未設定時はプレースホルダー表示）
- 積読詳細表示機能（進捗・ノルマ確認）
- 進捗更新機能（「今日読んだページ数」入力で現在ページに反映／現在ページ直接入力も可）
- 読書ステータス管理機能（未読・読書中・読了の切り替え／到達時は「読了にする」を強調）
- 読了期限の変更（延長）機能（延長回数の表示）
- Googleカレンダー連携機能（MVP：予定作成画面へのリンク生成、OAuth不要）
- 賞味期限ビジュアライザー機能（CSS版：7日/3日/1日の段階で色褪せ）
- マイページ表示機能（読了履歴・アカウント設定の統合ページ）
- パスワード変更機能（ログイン後にマイページから変更）
- メールアドレス変更機能（確認メールによる本人確認→変更完了→再ログイン誘導）

---

## テーブル詳細

### usersテーブル（ユーザー情報）

ユーザーアカウントを管理するテーブル。Devise gemによる認証機能を使用します。

- **id** : 主キー / bigint型
- **email** : ログイン認証用のメールアドレス / string型 / ユニーク制約・NOT NULL制約 / 例: taro@example.com
- **encrypted_password** : 暗号化されたパスワード / string型 / NOT NULL制約 / Deviseが自動管理
- **nickname** : ユーザーの表示名（ニックネーム） / string型 / NULL許可 / マイページの「ユーザー名」表示に使用（MVP）／積読タイムライン（本リリース）でも実名の代わりに表示 / 例: たろう
- **google_uid** : GoogleユーザーID / string型 / NULL許可 / **本リリース用**（OAuth認証導入時に使用）
- **google_access_token** : Googleアクセストークン / string型 / NULL許可 / **本リリース用**
- **google_refresh_token** : Googleリフレッシュトークン / string型 / NULL許可 / **本リリース用**
- **google_token_expires_at** : アクセストークンの有効期限 / datetime型 / NULL許可 / **本リリース用**
- **created_at** : レコード作成日時 / datetime型
- **updated_at** : レコード更新日時 / datetime型

**備考：**

- Deviseによる標準的な認証機能を実装
- nicknameはMVPのマイページで「ユーザー名」として表示するため、MVPから使用する（未設定時はメールアドレスをフォールバック表示する想定）
- nicknameは本リリースの積読タイムラインでも実名の代わりに使用される
- google_uid / google_access_token / google_refresh_token / google_token_expires_at は本リリースでOAuth認証（Googleカレンダー自動挿入）を導入する際に使用する。MVPではこれらのカラムは使用しない

---

### booksテーブル（積読本）

ユーザーが登録した積読本の情報を管理するテーブル。本サービスの中核となるデータモデルです。

- **id** : 主キー / bigint型
- **user_id** : ユーザーID（外部キー） / bigint型 / NOT NULL制約 / usersテーブルへの参照
- **title** : 本のタイトル / string型 / NOT NULL制約 / 例: リーダブルコード
- **author** : 著者名 / string型 / NULL許可 / 例: Dustin Boswell
- **total_pages** : 本の総ページ数 / integer型 / NOT NULL制約 / 例: 260
- **target_pages** : 読了対象ページ数 / integer型 / NOT NULL制約 / 初期値=total_pages / 索引や付録を除いた範囲を設定可能 / 例: 240
- **current_page** : 現在読んでいるページ / integer型 / デフォルト値: 0 / NOT NULL制約 / 進捗更新で増加 / 例: 120
- **deadline** : 読了期限（賞味期限） / date型 / NOT NULL制約 / いつまでに読み終えるか / 例: 2026-02-15
- **status** : 読書ステータス / integer型 / デフォルト値: 0 / NOT NULL制約 / enum値（0: 未読、1: 読書中、2: 読了） / 初回の進捗記録（current_page更新）時に 0→1 へ自動変移 / current_page が target_pages に達し「読了にする」を押した時点で 1→2 へ変移し completed_at をセット
- **cover_image** : 書影画像 / Active Storage で管理（`has_one_attached :cover_image`）/ NULL許可 / booksテーブルにカラムは持たない（`active_storage_attachments` / `active_storage_blobs` テーブルで管理）/ 未設定時はプレースホルダー画像を表示
- **extension_count** : 期限延長の回数 / integer型 / デフォルト値: 0 / NOT NULL制約 / 延長は無制限だが可視化して"言い訳"を見える化
- **completed_at** : 読了日時 / datetime型 / NULL許可 / status を 読了（2）に更新した際にセット / マイページの「読了履歴」で読了日として表示 / 例: 2026-02-10 21:30:00
- **is_public** : 積読タイムラインでの公開可否 / boolean型 / デフォルト値: false / NOT NULL制約 / **本リリース用の機能**（MVPの画面では設定UIなし）
- **created_at** : レコード作成日時 / datetime型
- **updated_at** : レコード更新日時 / datetime型

**備考：**

- ノルマ計算式：⌈(target_pages - current_page) / (今日を含む残日数)⌉
- 賞味期限ビジュアライザーは、deadlineまでの日数に応じて書影のCSS（sepia + opacity）を変化
- extension_countは延長回数を記録し、詳細画面に表示（制限なし、"自分への言い訳"として可視化）
- completed_atはstatus=2（読了）へ更新した時点でDBサーバー側がセット（`Time.current`）。マイページの読了履歴で読了日として利用する
- マイページに表示される「連続読書日数」は、booksテーブルの `updated_at` を利用し「当日に進捗更新（current_page変更）が行われた日付」を集計して算出する（MVP簡易実装）。複数冊の中で1冊でも更新があれば「読んだ日」とカウントする
- is_publicがtrueの本のみ、積読タイムライン（本リリース）に表示される

---

### timeline_eventsテーブル（積読タイムライン）

**本リリース用の機能**。他のユーザーの積読状況や進捗をイベント単位で表示し、相互の刺激で継続を支援します。

- **id** : 主キー / bigint型
- **user_id** : ユーザーID（外部キー） / bigint型 / NOT NULL制約 / usersテーブルへの参照
- **book_id** : 本ID（外部キー） / bigint型 / NOT NULL制約 / booksテーブルへの参照
- **event_type** : イベントの種類 / integer型 / NOT NULL制約 / enum値（0: 新規登録、1: 期限3日前、2: 読了） / 同一ユーザー・同一本の「期限3日前」は1回のみ発火
- **progress_percentage** : 進捗率（%） / decimal型 / NULL許可 / 計算式: current_page / target_pages × 100 / 例: 50.5
- **published_at** : イベント公開日時 / datetime型 / NOT NULL制約 / タイムラインの表示順に使用
- **created_at** : レコード作成日時 / datetime型
- **updated_at** : レコード更新日時 / datetime型

**備考：**

- is_public=trueの本のみイベント生成対象
- event_type=1（期限3日前）は、（期限日 - 3日）のJST 00:00基準で判定し、同一ユーザー・同一本につき1回のみ発火
- バックグラウンド処理（GitHub Actions cron）で毎日の期限チェックとイベント生成を実行

---

### reading_speed_recordsテーブル（読書スピード計測）

**本リリース用の機能**。タイマー機能で1ページあたりの読書時間を計測・保存し、ノルマ計算の精度を向上させます。

- **id** : 主キー / bigint型
- **user_id** : ユーザーID（外部キー） / bigint型 / NOT NULL制約 / usersテーブルへの参照
- **book_id** : 本ID（外部キー） / bigint型 / NOT NULL制約 / booksテーブルへの参照
- **pages_read** : 計測時に読んだページ数 / integer型 / NOT NULL制約 / 例: 10
- **time_spent_seconds** : 読書にかかった時間（秒） / integer型 / NOT NULL制約 / 例: 1800（30分）
- **recorded_at** : 計測日時 / datetime型 / NOT NULL制約 / 例: 2026-02-01 20:30:00
- **created_at** : レコード作成日時 / datetime型
- **updated_at** : レコード更新日時 / datetime型

**備考：**

- 1ページあたりの平均読書時間 = time_spent_seconds / pages_read
- 蓄積されたデータから、時間（予定枠）⇄ページ（ノルマ）の換算精度を向上
- 本リリースで「読書する曜日/頻度」設定と組み合わせて、よりリアルなノルマ計算が可能に

---

### reading_logsテーブル（読書日ログ）

**本リリース用の機能**。連続読書日数を正確に集計するための専用テーブルです。MVPでは `books.updated_at` を日付集計して代用しますが、期限変更・書影変更でも `updated_at` が更新されるため精度が低くなる問題があります。本リリースでこのテーブルに移行することで、「進捗更新（current_page変更）が行われた日」のみを正確にカウントできます。

- **id** : 主キー / bigint型
- **user_id** : ユーザーID（外部キー） / bigint型 / NOT NULL制約 / usersテーブルへの参照
- **book_id** : 本ID（外部キー） / bigint型 / NOT NULL制約 / booksテーブルへの参照
- **read_date** : 読書した日付 / date型 / NOT NULL制約 / 例: 2026-02-22
- **created_at** : レコード作成日時 / datetime型
- **updated_at** : レコード更新日時 / datetime型

**備考：**

- 進捗更新（current_page変更）時にアプリケーション側で当日分のレコードを upsert する
- 同一ユーザー・同一本・同一日付の重複レコードは不要なため、`(user_id, book_id, read_date)` にユニーク制約を検討する
- 連続読書日数の計算：ユーザーごとに `read_date` の日付連続性を集計（複数冊のうち1冊でも更新があれば「読んだ日」とカウント）

---

### reading_preferencesテーブル（読書設定）

**本リリース用の機能**。ユーザーごとの読書習慣（曜日・頻度・時間帯）を管理し、Googleカレンダー自動挿入やノルマ計算に活用します。

- **id** : 主キー / bigint型
- **user_id** : ユーザーID（外部キー） / bigint型 / ユニーク制約・NOT NULL制約 / usersテーブルへの参照 / 1ユーザーにつき1レコード
- **days** : 読書する曜日 / string型 / NULL許可 / 例: "月,水,金" または "1,3,5" / カンマ区切りで曜日を指定 / **意図的な非正規化**（厳密には `reading_preference_days(reading_preference_id, day_of_week)` に分離が正規形だが、実装コスト優先でカンマ区切り文字列で保持）
- **frequency** : 週あたりの読書日数 / integer型 / NULL許可 / 例: 3（週3日）
- **preferred_time_start** : 読書可能な開始時刻 / time型 / NULL許可 / 例: 19:00
- **preferred_time_end** : 読書可能な終了時刻 / time型 / NULL許可 / 例: 21:00
- **created_at** : レコード作成日時 / datetime型
- **updated_at** : レコード更新日時 / datetime型

**備考：**

- 本リリースでOAuth認証後、指定時間帯にGoogleカレンダーの読書スロットを自動挿入
- daysまたはfrequencyを使って、"読む日"のみで逆算したノルマ計算が可能
- 将来的にはfreebusy APIで空き時間を解析し、最適な時間に自動挿入する拡張も検討

---

## リレーションシップ

### users ← books（1対多）

- 1人のユーザーは複数の本を登録できる
- 1冊の本は1人のユーザーに所属する

### users ← reading_preferences（1対1）

- 1人のユーザーは1つの読書設定を持つ
- user_idにユニーク制約

### users ← timeline_events（1対多）

- 1人のユーザーは複数のタイムラインイベントを生成できる
- 1つのイベントは1人のユーザーに所属する

### users ← reading_speed_records（1対多）

- 1人のユーザーは複数の読書スピード計測記録を持つ
- 1つの記録は1人のユーザーに所属する

### books ← timeline_events（1対多）

- 1冊の本は複数のタイムラインイベント（新規登録/期限3日前/読了）を生成できる
- 1つのイベントは1冊の本に関連する

### books ← reading_speed_records（1対多）

- 1冊の本は複数の読書スピード計測記録を持つ
- 1つの記録は1冊の本に関連する

### users ← reading_logs（1対多）

- 1人のユーザーは複数の読書日ログを持つ
- 1つのログは1人のユーザーに所属する

### books ← reading_logs（1対多）

- 1冊の本は複数の読書日ログを持つ
- 1つのログは1冊の本に関連する

---

## 設計方針

### MVPでの実装範囲

- **users**、**books**テーブルのみ実装
- 書影は Active Storage（`has_one_attached :cover_image`）で管理するため、books テーブルに `cover_image` カラムは追加しない
- Googleカレンダー連携は簡易版（event create URL生成）のため、カレンダー予定のDB保存は不要
- 賞味期限ビジュアライザーはCSS（filter: sepia + opacity）で実装
- マイページの「連続読書日数」は `books.updated_at` を日付集計して算出する簡易実装（専用テーブルは設けない）
- メールアドレス変更・パスワード変更はDeviseの標準機能で実装（追加テーブル不要）

### 本リリースでの追加範囲

- **timeline_events**、**reading_speed_records**、**reading_preferences**、**reading_logs**テーブルを追加
- **users**テーブルに Google OAuth トークン用カラム（`google_uid` / `google_access_token` / `google_refresh_token` / `google_token_expires_at`）を追加
- Googleカレンダー連携をOAuth認証版に拡張（events.insert API使用）
- バックグラウンド処理（GitHub Actions cron）で期限チェック・通知送信・イベント生成を定期実行
- 連続読書日数の集計を `books.updated_at` 代用から `reading_logs` テーブルによる正確な集計に移行

### 将来の拡張可能性

- OGP画像生成（Cloudinary）による読了シェア機能の強化
- 積読タイムラインへのリアクション機能（コメント・スタンプ）
- 読書イベント機能（期間限定の共有ルーム）
- ジョブキュー（solid_queue）導入による非同期処理の最適化
