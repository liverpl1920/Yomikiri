# 設計書: Project AutomationのPR作成時実行停止

## アーキテクチャ概要

GitHub Actions のイベントトリガー定義を最小限に調整する構成。

```
Issue opened/reopened -> add_to_project job 実行
PR closed + merged==true -> move_to_done job 実行
PR opened -> 何も実行しない
```

## コンポーネント設計

### 1. `.github/workflows/project-automation.yml`

**責務**:
- Project Automation のイベントトリガーを定義する。
- PR マージ時に linked issue を Done へ移動する。

**実装の要点**:
- `on.pull_request.types` を `closed` のみにする。
- `move_to_done` ジョブの `if` 条件 (`closed` + `merged == true`) は現状維持する。

### 2. 運用ドキュメント

**責務**:
- 開発者に「いつ workflow が動くか」を伝える。

**実装の要点**:
- PR 作成時には実行しない点を明記する。
- Issue の opened/reopened と PR merged 時の実行を明記する。

## データフロー

### Project Automation 実行判定
```
1. GitHub event を受信
2. event_name/action で workflow のトリガー判定
3. jobs.if 条件で実行可否を最終判定
4. add_to_project または move_to_done を実行
```

## エラーハンドリング戦略

### 設定ミス防止
- YAML 構文が壊れていないことをチェックする。
- `move_to_done` の条件式を維持し、想定外イベント起動を抑制する。

## テスト戦略

### 静的確認
- workflow YAML を読み、`pull_request.types` から `opened` が除外されていることを確認。
- `issues.types` が `opened, reopened` のまま維持されていることを確認。
- `move_to_done` の `if` 条件が `closed` + `merged == true` を維持していることを確認。

### 実行系確認
- `bundle exec rspec`
- `bundle exec rubocop`

## 依存ライブラリ

追加なし。

## ディレクトリ構造

```
.github/workflows/project-automation.yml   # 変更
docs/development-workflow.md               # 変更（運用記述）
.steering/20260517-issue190-project-automation-pr-opened-stop/
	requirements.md                          # 新規
	design.md                                # 新規
	tasklist.md                              # 新規
```

## 実装の順序

1. workflow トリガーを修正
2. 運用ドキュメントを更新
3. テスト/リントで回帰確認
4. ステアリングの振り返りを記載

## セキュリティ考慮事項

- Token や Project ID など secret 参照部分は変更しない。

## パフォーマンス考慮事項

- 不要な workflow 起動を減らし、Actions ノイズと実行時間を削減する。

## 将来の拡張性

- 将来的に PR `reopened` 時だけ実行したい場合は、`pull_request.types` に個別追加できる設計を維持する。
