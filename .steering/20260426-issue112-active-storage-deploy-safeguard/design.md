# 設計書

## アーキテクチャ概要

本対応はアプリケーションコードの機能追加ではなく、運用ドキュメント層での安全性向上を目的とする。
既存の Rails/Render 構成を変更せず、以下の 2 つを明文化する。

1. デプロイ前提条件（Render 環境変数・S3 バケット）
2. マージ順序（`feature/#25` 先行、`feature/#26` 後続）

```
Issue #112
  -> docs/development-workflow.md に本番手順を追加
  -> README.md に運用注意点を追加
  -> PR 時にチェック可能なチェックリストとして運用
```

## コンポーネント設計

### 1. docs/development-workflow.md 更新

**責務**:
- 日々の開発フローに Active Storage 本番反映の前提チェックを組み込む。
- PR/マージ前に確認すべき運用項目を定義する。

**実装の要点**:
- 既存のワークフロー文書の構造を崩さずセクション追加する。
- 手順はコピペ可能なチェックリスト形式で記載する。

### 2. README.md 更新

**責務**:
- リポジトリ初見者にも本番リスク（`sync: false` と `:local` の注意）を伝える。
- Active Storage 反映の順序依存をトップレベル文書で可視化する。

**実装の要点**:
- サービス概要の流れを壊さないよう「運用メモ」セクションを追加する。
- 実装済み/未実装の境界を明確にする。

## データフロー

### Active Storage 本番反映判断

1. S3 バケット準備済みであることを確認する。
2. Render ダッシュボードに AWS 環境変数 4 種を設定する。
3. `feature/#25-active-storage-setup` を main にマージする。
4. Render 自動デプロイが成功して `/up` が正常応答することを確認する。
5. その後に `feature/#26-cover-image-upload` をマージする。

## エラーハンドリング戦略

### 運用エラーの扱い

- 設定不足（AWS 環境変数未設定）は「マージ前チェックでブロック」する。
- 順序違反は「レビュー時チェック項目」で検知する。

## テスト戦略

### ドキュメント変更の検証
- `bundle exec rspec` を実行し既存仕様に影響がないことを確認。
- `bundle exec rubocop` を実行しコード品質が維持されることを確認。

### 追加検証
- `npm test` / `npm run lint` / `npm run typecheck` を実行し、JS/TS チェックの適用可否を確認する。

## 依存ライブラリ

新規追加なし。

## ディレクトリ構造

```
.steering/20260426-issue112-active-storage-deploy-safeguard/
  requirements.md
  design.md
  tasklist.md

docs/
  development-workflow.md  # 更新

README.md                  # 更新
```

## 実装の順序

1. ステアリング作成（requirements/design/tasklist）
2. `docs/development-workflow.md` 更新
3. `README.md` 更新
4. 検証（implementation-validator, rspec, rubocop, npm 系）
5. tasklist 振り返り更新
6. コミット、push、PR、CI 確認

## セキュリティ考慮事項

- 環境変数の値はドキュメントに記載せず、キー名のみ記載する。
- 認証情報は Render ダッシュボードで管理し、リポジトリに保存しない。

## パフォーマンス考慮事項

- 本対応はドキュメント更新のみのため、実行時パフォーマンスへの影響はない。

## 将来の拡張性

- 将来的にデプロイチェックを CI に自動化する場合、今回のチェックリストをそのまま Action の要件定義として利用できる。
