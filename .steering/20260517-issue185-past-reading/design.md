# 設計書

## アーキテクチャ概要

基本的なMVCアーキテクチャを踏襲し、既存の積読登録フローを拡張する形で実装します。
- **View層**: 書籍登録フォーム(`app/views/books/new.html.erb`)に「過去読了フラグ」と「読了日」フィールドを追加
- **Controller層**: `BooksController#create`でパラメータを受け取り、過去読了ロジックを呼び出し
- **Model層**: `Book`モデルの`before_save`フック内で、過去読了フラグに応じた自動設定を実装

## コンポーネント設計

### 1. View層: 書籍登録フォーム（`app/views/books/new.html.erb`）

**責務**:
- 通常の積読登録フォームを提供
- 「過去に読んだ本として登録」チェックボックスを追加
- チェック時に読了日入力フィールドを表示（JavaScript制御）

**実装の要点**:
- 既存フォーム構造を維持し、新しいフィールドを追加（互換性維持）
- 読了日フィールドは日付入力型（`type="date"`）を使用
- クライアント側のバリデーション（必須ではないが、UX向上のため）

### 2. Controller層: BooksController#create

**責務**:
- POSTされたパラメータを受け取る
- `book_params`で安全にパラメータを抽出
- モデルの保存に委譲

**実装の要点**:
- 既存の`create`アクションは変更不要（パラメータ受け取りのみ）
- `book_params`に新しいパラメータ(`is_past_reading`, `completed_at`)を追加

### 3. Model層: Book（`app/models/book.rb`）

**責務**:
- `is_past_reading`フラグの受け取り
- `before_save`フック内で、フラグが立っている場合に以下を自動設定
  - `status = :completed`
  - `current_page = target_pages`
  - `completed_at = 入力値 or Time.current`
- 読了日のバリデーション

**実装の要点**:
- `is_past_reading`は属性ではなく、一時的なパラメータ
- `before_save`フック内で状態を設定し、`completed_at`を確定
- `completed_at`が指定された場合はそれを使用、未指定なら`Time.current`
- 既存のバリデーションルール（`deadline_cannot_be_in_the_past`など）との互換性を維持

## バリデーション戦略

### 既存バリデーション
- `deadline_cannot_be_in_the_past`: 読了期限は未来日である必要がある
  - 過去読了登録時も同じ制約を適用（読了期限は未来日）

### 新規バリデーション
1. **読了日の形式チェック**
	- 有効な日付形式か確認
	- パースに失敗した場合はエラー

2. **読了日の範囲チェック**
	- 未来日でないか確認
	- 過去読了登録の場合のみ適用

### エラーハンドリング

**不正な日付フォーマット**:
- エラーメッセージ: `"読了日の形式が不正です"`
- レスポンス: `422 Unprocessable Entity`

**未来日入力**:
- エラーメッセージ: `"読了日は今日以前の日付を指定してください"`
- レスポンス: `422 Unprocessable Entity`

## データフロー

### ユースケース1: 通常の積読登録（未読）
```
1. ユーザーが「新規登録」をクリック
2. フォームが表示される
3. 「過去に読んだ本として登録」はチェックしない
4. POSTされたパラメータ: { title, author, total_pages, target_pages, deadline, ... }
5. BooksController#createで受け取り
6. Book.create(book_params)で保存
7. before_saveフック: is_past_reading=falseのため、何もしない
8. status=:unread（デフォルト）で保存
9. リダイレクト
```

### ユースケース2: 過去読了登録（読了日あり）
```
1. ユーザーが「新規登録」をクリック
2. フォームが表示される
3. 「過去に読んだ本として登録」をチェック
4. 読了日入力フィールドが表示される
5. 読了日を入力（例: 2026-05-10）
6. POSTされたパラメータ: { title, author, total_pages, target_pages, deadline, is_past_reading: true, completed_at: "2026-05-10", ... }
7. BooksController#createで受け取り
8. Book.create(book_params)で保存
9. before_saveフック内:
	- is_past_reading=trueを検出
	- status = :completed
	- current_page = target_pages
	- completed_at = Date.parse("2026-05-10").to_time
10. バリデーション: 読了日が未来日でないか確認
11. 保存完了
12. リダイレクト
```

### ユースケース3: 過去読了登録（読了日なし）
```
1. ユーザーが「新規登録」をクリック
2. フォームが表示される
3. 「過去に読んだ本として登録」をチェック
4. 読了日入力フィールドが表示されるが、入力しない
5. POSTされたパラメータ: { title, author, total_pages, target_pages, deadline, is_past_reading: true, completed_at: nil, ... }
6. BooksController#createで受け取り
7. Book.create(book_params)で保存
8. before_saveフック内:
	- is_past_reading=trueを検出
	- status = :completed
	- current_page = target_pages
	- completed_at = Time.current（フック内で設定）
9. 保存完了
10. リダイレクト
```

## テスト戦略

### ユニットテスト（Model: `spec/models/book_spec.rb`）

#### 通常の積読登録
- 新規レコード作成時、`status=:unread`, `current_page=0`が設定される（既存テスト）

#### 過去読了登録
- `is_past_reading=true`の場合、`status=:completed`が設定される
- `is_past_reading=true`の場合、`current_page=target_pages`が設定される
- 読了日が入力された場合、`completed_at`がその値で設定される
- 読了日が未入力の場合、`completed_at=Time.current`で設定される

#### バリデーション
- 不正な日付フォーマットでエラーが発生する（if applicable）
- 未来日でエラーが発生する

### 統合テスト（Request: `spec/requests/books_spec.rb`）

#### 通常の積読登録フロー
- `POST /books` で正常に登録できる
- 通常の積読を登録後、一覧に表示される
- 詳細ページで正しく表示される

#### 過去読了登録フロー（読了日あり）
- `POST /books` で `is_past_reading=true, completed_at="2026-05-10"` を送信
- 正常に登録される
- `status=:completed`, `current_page=target_pages`, `completed_at=2026-05-10` が保存される
- 一覧では読了本として表示される（期限順ソートで読了本の後ろに来る）

#### 過去読了登録フロー（読了日なし）
- `POST /books` で `is_past_reading=true, completed_at=""` を送信
- 正常に登録される
- `status=:completed`, `current_page=target_pages`, `completed_at=Time.current` が保存される

#### エラーケース
- 不正な日付フォーマット: `422` レスポンス
- 未来日: `422` レスポンス
- 必須フィールドが不足: `422` レスポンス

## ファイル変更一覧

1. `app/views/books/new.html.erb` - フォームに新しいフィールドを追加
2. `app/controllers/books_controller.rb` - `book_params`に新しいパラメータを追加
3. `app/models/book.rb` - `before_save`フックを拡張
4. `spec/requests/books_spec.rb` - テストを追加・更新
5. `spec/models/book_spec.rb` - バリデーションテストを追加（if necessary）

## 実装の順序

1. **Modelの変更**（`app/models/book.rb`）
	- `before_save`フックを拡張
	- バリデーションロジックを追加

2. **Controller の変更**（`app/controllers/books_controller.rb`）
	- `book_params`に新しいパラメータを追加

3. **View の変更**（`app/views/books/new.html.erb`）
	- フォームに新しいフィールドを追加
	- JavaScriptで表示/非表示を制御

4. **テストの実装**（`spec/requests/books_spec.rb`, `spec/models/book_spec.rb`）
	- テストスイートを追加・更新
	- すべてのユースケースをカバー

## セキュリティ考慮事項

- `book_params`で新しいパラメータをホワイトリストに含める（Strong Parameters）
- 読了日は日付型で受け取り、文字列インジェクションを防ぐ
- ユーザーが他ユーザーの本を登録しないよう、`current_user.books.build`を使用（既存）

## パフォーマンス考慮事項

- `before_save`フックの処理は軽量（属性代入のみ）であり、パフォーマンスへの影響はない
- 新しいバリデーション処理も簡潔（日付パースと範囲チェック）

## 将来の拡張性

- 読了日の後付け編集機能を追加する場合、`update`アクション内で同じバリデーションロジックを適用
- 読了日の CSV インポート機能を追加する場合、同じバリデーション・自動設定ロジックを再利用


