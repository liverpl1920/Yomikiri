# 設計書

## アーキテクチャ概要

Rails 標準 MVC と Devise の `PasswordsController` 拡張を継続利用する。`Users::PasswordsController` の `create` をオーバーライドし、メール送信中の配信例外のみをアプリ境界で吸収して、ナビゲーション可能なレスポンスへ変換する。

```
[W-9: /users/password/new]
	-> POST /users/password
			-> Users::PasswordsController#create
					-> Devise の send_reset_password_instructions
							-> ActionMailer SMTP(sendgrid)
								 |- 正常: ログイン画面へリダイレクト
								 |- 異常: 例外補足 -> ログ記録 -> フラッシュ表示 -> 再試行導線維持
```

## コンポーネント設計

### 1. Users::PasswordsController

**責務**:
- Devise のパスワード再設定送信処理を委譲しつつ、メール配信例外をハンドリングする。
- 障害時に機微情報を表示せず、ユーザーには再試行可能なメッセージを返す。

**実装の要点**:
- `create` をオーバーライドして `super` を実行。
- `Net::SMTP*`, `Timeout::Error`, `SocketError`, `Errno::*` など SMTP/接続関連例外を rescue。
- `Rails.logger.error` に controller 名、例外クラス、メッセージを記録。
- `flash[:alert]` を設定し、`new_user_password_path` へリダイレクト。

### 2. Request Spec (`spec/requests/passwords_spec.rb`)

**責務**:
- 送信例外時に 500 が返らずリダイレクトになることを担保する。

**実装の要点**:
- `User.send_reset_password_instructions` をスタブして `Net::SMTPAuthenticationError` を送出。
- `POST /users/password` 実行後、`302/303` とリダイレクト先を検証。
- フラッシュメッセージ存在を検証。

## データフロー

### パスワード再設定送信（障害時）
```
1. ユーザーがメールアドレスを入力して送信
2. Controller が Devise の送信処理を呼ぶ
3. SMTP 接続で例外発生
4. Controller が例外を補足しログ出力
5. ユーザーへ一般化メッセージを表示して再設定画面へ遷移
```

## エラーハンドリング戦略

### ハンドリング方針

- 対象は「メール配信インフラ障害」に限定し、入力バリデーション系は Devise 標準に委譲する。
- ユーザー向けには内部事情を開示しない。
- 運用向けにはログから障害追跡できる粒度を確保する。

## テスト戦略

### ユニット/リクエストテスト
- `POST /users/password` 正常系（既存）
- `POST /users/password` 送信例外系（追加）

### 統合テスト
- 既存システムスペック `spec/system/auth/password_reset_spec.rb` の回帰確認

## 依存ライブラリ

新規追加なし。

## ディレクトリ構造

```
app/
	controllers/
		users/
			passwords_controller.rb      # 変更
spec/
	requests/
		passwords_spec.rb              # 変更
.steering/
	20260509-issue170-password-reset-mail-delivery/
		requirements.md
		design.md
		tasklist.md
```

## 実装の順序

1. PasswordsController に配信例外ハンドリング追加
2. Request spec に異常系を追加
3. RSpec / RuboCop を実行して回帰確認
4. 実装バリデータで品質確認

## セキュリティ考慮事項

- 例外メッセージをそのまま画面表示しない（情報漏えい防止）。
- Devise の paranoid モード挙動を維持し、ユーザー存在有無の漏えいを防ぐ。

## パフォーマンス考慮事項

- 追加処理は例外発生時のみで、正常系リクエストへの負荷影響は最小。

## 将来の拡張性

- 必要に応じて通知先（Sentry 等）に同例外を送るフックを追加可能。
- メール配信状態の監視ダッシュボード追加時にも、例外境界がコントローラーに明示されているため拡張しやすい。
