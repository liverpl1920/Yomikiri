# タスクリスト

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

### 必須ルール
- **全てのタスクを`[x]`にすること**
- 未完了タスク（`[ ]`）を残したまま作業を終了しない

---

## フェーズ1: 事前整理

- [x] issue #270 の現行 Active Storage 設定を確認する
  - [x] `production.rb`, `storage.yml`, `render.yaml`, `README.md` の B2 影響範囲を確認する
  - [x] 既存の validator/spec を確認して変更点を整理する

- [x] B2 切り替え方針を文書化する
  - [x] B2 用の env var 名と endpoint 方針を決める
  - [x] 必要なドキュメント更新範囲を確定する

## フェーズ2: 実装

- [x] production の Active Storage を Backblaze B2 に切り替える
  - [x] B2 用 validator を実装する
  - [x] `config/environments/production.rb` の service 設定を更新する
  - [x] `config/storage.yml` を B2 用に更新する

- [x] 本番デプロイ設定を B2 用に更新する
  - [x] `render.yaml` の環境変数を更新する
  - [x] `README.md` と関連ドキュメントの案内を更新する

## フェーズ3: テスト

- [x] 回帰テストを追加する
  - [x] B2 validator の spec を更新または追加する
  - [x] production 設定の spec を更新する
  - [x] storage.yml の設定 spec を追加する

## フェーズ4: 品質チェック

- [x] RSpec を実行して通過を確認する
- [x] RuboCop を実行して通過を確認する

## フェーズ5: 振り返り

- [x] tasklist に振り返りを記入する

---

## 実装後の振り返り

### 実装完了日
2026-05-31

### 計画と実績の差分

**計画と異なった点**:
- Backblaze B2 用の endpoint 変数を必須項目に追加した。
- production の service 名を `:backblaze` に変更し、`storage.yml` も B2 用に切り替えた。

**新たに必要になったタスク**:
- `spec/config/storage_config_spec.rb` を追加し、`storage.yml` の B2 定義を直接検証した。
- ドキュメントの Active Storage 反映手順を Backblaze B2 前提に更新した。

**技術的理由でスキップしたタスク**（該当する場合のみ）:
- なし

### 学んだこと

**技術的な学び**:
- Backblaze B2 は S3 互換でも endpoint と `force_path_style` を明示しておくと設定意図が読みやすい。
- production 起動時の fail-fast と storage.yml の直接 spec を組み合わせると、設定ずれを早く検知できる。

**プロセス上の改善点**:
- 先に focused spec を回してから全体の RSpec / RuboCop に広げると、修正範囲を狭く保てる。
- steering の tasklist を実装後すぐ更新すると、後続の振り返りがそのまま書ける。

### 次回への改善提案
- 環境変数名を切り替える変更では、README だけでなく deployment workflow まで一括で追従させる。
- S3 互換ストレージの切り替えでは、service 名・endpoint・path style の 3 点をセットで spec 化する。
