# 設計書

## アーキテクチャ概要

本機能は、MVCにおけるモデル層のビジネスロジックの改善です。
既存の `User`、`Book`、`ReadingLog` の関係性を整理し、`User` から `ReadingLog` を直接取得可能にすることで、読みやすくパフォーマンスの高いクエリとロジックを実現します。

```
+----------+          +----------+          +-------------+
|   User   | -------> |   Book   | -------> | ReadingLog  |
+----------+          +----------+          +-------------+
     |                                             ^
     +-----------------(through: :books)-----------+
```

## コンポーネント設計

### 1. Userモデル (`app/models/user.rb`)

**責責**:
- `has_many :reading_logs, through: :books` アソシエーションの追加
- `consecutive_reading_days` の計算元を `books.pluck(:updated_at)` から `reading_logs.pluck(:read_at)` に変更

**実装の要点**:
- 関連先の `reading_logs` から `read_at` カラムの値を `pluck` します。これによりSQLレベルで必要なカラムだけをロードしメモリ消費を抑えます。
- タイムゾーンの影響を受けないよう、`reading_logs.read_at` は `Date` 型で保存されているため、そのまま比較に用いることができます。
- 既存の判定アルゴリズム（今日または昨日から始まる連続日数の計測）はそのまま流用可能です。

```ruby
  has_many :reading_logs, through: :books

  def consecutive_reading_days
    dates = reading_logs.pluck(:read_at).uniq.sort.reverse
    return 0 if dates.empty?

    streak = 0
    check_date = dates.include?(Date.current) ? Date.current : Date.current - 1.day
    dates.each do |date|
      if date == check_date
        streak += 1
        check_date -= 1.day
      end
    end
    streak
  end
```

## データフロー

### 連続読書日数の取得時
1. マイページ表示時（`MypagesController#show`）またはダッシュボード表示時に、`current_user.consecutive_reading_days` が呼び出される。
2. データベースからユーザーが持つすべての本の読書ログの `read_at` を取得する。
3. Ruby側で重複を排除し、降順ソートされた配列を作成する。
4. 今日もしくは昨日を起点として、連続して存在する日付をカウントし、日数を返す。
5. ビュー（`app/views/mypages/show.html.erb` 等）に結果が表示される。

## テスト戦略

### ユニットテスト (`spec/models/user_spec.rb`)
- `User#consecutive_reading_days` のテストデータを、書籍の `updated_at` 更新から `reading_logs` の `read_at` レコード作成に変更する。
- 以下のケースを検証する：
  1. 今日から過去へ連続して読書ログがある場合（例：今日、昨日、一昨日にログがあり、結果が3になること）。
  2. 今日はログがないが、昨日から過去へ連続して読書ログがある場合（例：昨日、一昨日にログがあり、結果が2になること）。
  3. 連続が途切れている場合（例：今日、一昨日にログがあり、結果が1になること）。
  4. 読書ログが全く存在しない場合、結果が0になること。

## ディレクトリ構造

変更が発生する主なファイル：
```
app/
├── models/
│   └── user.rb (変更: アソシエーション追加、連続読書日数メソッドの修正)
spec/
├── models/
│   └── user_spec.rb (変更: テストデータの作成方法を reading_logs に変更)
```

## 実装の順序

1. `app/models/user.rb` にアソシエーション `has_many :reading_logs, through: :books` を追加。
2. `app/models/user.rb` の `consecutive_reading_days` メソッドを修正。
3. `spec/models/user_spec.rb` のテストデータを `reading_logs` に修正し、RSpecを実行して正しくテストが通ることを検証。
4. 開発環境での動作確認と全体のテスト、Linterの実行。
