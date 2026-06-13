# 設計書

## アーキテクチャ概要

本機能は、既存の MVC パターンおよび Service パターン（`ReadingReportSummaryService`）に従います。

```
[Browser (View)] -> (Request) -> [MypagesController]
                                      | (Call)
                                      v
                               [ReadingReportSummaryService]
                                      | (Query & Aggregate)
                                      v
                               [Book & ReadingLog Models]
```

## コンポーネント設計

### 1. `Book` モデル
**責務**:
- 書籍のデータを管理し、i18n の仕組みを用いて各カテゴリ（種類）の日本語表記をマッピングする `categories_i18n` クラスメソッドを提供します。

**実装の要点**:
- `Book.categories` ハッシュの各キーに対応する日本語訳を `I18n.t("book.category.#{key}")` から引き出して、`{"other" => "その他", "literature" => "純文学", ...}` のようなハッシュを返すようにします。

### 2. `ReadingReportSummaryService`
**責務**:
- 指定された期間（週次、月次、カスタムなど）内の読書実績（`ReadingLog`）から、書籍の `category` ごとの合計読了ページ数を集計し、その比率（%）を算出します。

**実装の要点**:
- `scoped_logs.group("books.category").sum(:pages_read)` にて SQL レベルでの集計を行います。
- 得られた結果のキー（カテゴリの integer 値）を `Book.categories.key(val.to_i)` を使って enum の string キー（例: `"literature"`) に変換し、さらに日本語の表示名および百分率の比率を取得してハッシュの配列として返却します。
- `genres` メソッドは使用しなくなるため、`categories` メソッドに置き換えます。

### 3. `stats.html.erb` (View) & CSS (Styles)
**責務**:
- 統計結果を視認性の高いドーナツ型円グラフと、カラーコードを含む凡例リストに整形して表示します。

**実装の要点**:
- ドーナツグラフは、CSS の `conic-gradient` を利用して HTML 内の単一 `div` 要素の `style` 属性に動的にグラデーション角度を割り当てることで描画します。
- ドーナツ型にするために、擬似要素 `::after` を使って中央に背景色と同色の円を重ねます。
- 各カテゴリに一意のカラーを割り当てるために、カラーマップ（ハッシュ）を ERB / CSS に定義します。
- 配置順は、「書籍別の読了ページ内訳」の直下に移動します。

## データフロー

### 統計ページの表示フロー
```
1. ユーザーが統計ページ（/mypage/stats）にアクセスする
2. MypagesController#stats が呼び出される
3. Controller が ReadingReportSummaryService.call を実行して統計サマリー（@summary）を取得する
   - Service 内で categories メソッドが走り、期間内の category ごとのページ読了数を集計する
4. Controller から View へデータを渡し、View が conic-gradient のインラインスタイルを組み立てる
5. ブラウザ側でドーナツグラフおよび凡例がレンダリングされる
```

## テスト戦略

### ユニットテスト (`spec/services/reading_report_summary_service_spec.rb`)
- 期間内の読書ログから、各本に設定されている `category` 別に読了ページ数が正しく集計され、比率が計算されているかを検証します。
- カテゴリが存在しない本、あるいは読書ログがない場合の挙動を検証します。
- 順序が「読了ページ数順」の降順になっていることを確認します。

## ディレクトリ構造

```
app/
  assets/
    stylesheets/
      mypages.css (ドーナツグラフと凡例のスタイル追加)
  controllers/
    mypages_controller.rb (集計キーの参照変更)
  models/
    book.rb (categories_i18n メソッド追加)
  services/
    reading_report_summary_service.rb (genres メソッドを categories メソッドに変更)
  views/
    mypages/
      stats.html.erb (レイアウト変更、ドーナツグラフと凡例マークアップ)
spec/
  services/
    reading_report_summary_service_spec.rb (テストの genres -> categories への変更)
```

## 実装の順序

1. `Book` モデルに `categories_i18n` クラスメソッドを追加する
2. `ReadingReportSummaryService` に `categories` メソッドを追加し、`genres` を削除する
3. `spec/services/reading_report_summary_service_spec.rb` を修正して `categories` の集計テストに変更し、RSpec が通るか検証する
4. `stats.html.erb` の「ジャンル別読書ポートフォリオ」を「種類別読書ポートフォリオ」に差し替え、表示位置を「書籍別の読了ページ内訳」の直下へ移動する。横棒グラフを CSS `conic-gradient` ベースの円グラフに変更する
5. `mypages.css` にドーナツ型円グラフとレスポンシブな凡例のスタイルを追加する
6. 開発環境サーバ（あるいは system test / RSpec 全体）を実行して、見た目と動作を確認する

## セキュリティ考慮事項

- 特になし（ユーザーが入力したパラメータを SQL にそのまま展開しないよう、ActiveRecord の安全なクエリメソッド `group("books.category")` を使用します）。

## パフォーマンス考慮事項

- `scoped_logs` は既に `joins(:book)` されているため、`group("books.category").sum(:pages_read)` は単一の JOIN クエリで行われ、N+1 問題は発生しません。

## 将来の拡張性

- `Book` のカテゴリが今後増えた場合も、`Book.categories` の定義を追加するだけで自動的に統計ページに反映されます。
