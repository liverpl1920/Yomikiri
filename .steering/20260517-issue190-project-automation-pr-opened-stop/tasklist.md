# タスクリスト: Project AutomationのPR作成時実行停止

## 🚨 タスク完全完了の原則

**このファイルの全タスクが完了するまで作業を継続すること**

---

## フェーズ1: Workflow修正

- [x] `.github/workflows/project-automation.yml` の `pull_request.types` から `opened` を除外
	- [x] `issues.types` が `opened, reopened` のまま維持されていることを確認
	- [x] `move_to_done` 条件 (`closed` + `merged == true`) が維持されていることを確認

## フェーズ2: ドキュメント更新

- [x] 運用ドキュメントに実行タイミングを明記
	- [x] PR作成時に実行されないことを記載
	- [x] Issue opened/reopened と PR merged 時に実行されることを記載

## フェーズ3: 検証

- [x] `bundle exec rspec` が通ることを確認
- [x] `bundle exec rubocop` が通ることを確認
- [x] ワークフロー設定の静的確認（trigger条件）

## フェーズ4: 振り返り

- [x] 実装後の振り返りを記載

---

## 実装後の振り返り

### 実装完了日
2026-05-17

### 計画と実績の差分

**計画と異なった点**:
- `README.md` ではなく運用ドキュメント `docs/development-workflow.md` を更新対象とした（Issue 要件の「READMEまたは運用メモ」を満たすため）。
- プロンプトの `npm test/lint/typecheck` は Rails リポジトリ（`package.json` 不在）では実行できないため、プロジェクト標準の `bundle exec rspec` / `bundle exec rubocop` を検証コマンドとして採用した。

**新たに必要になったタスク**:
- 変更後の trigger 条件を `grep` で静的確認し、`issues` と `pull_request` の対象イベントが要件どおりであることを証跡化した。

### 学んだこと

**技術的な学び**:
- Project Automation のノイズ削減は `on.pull_request.types` の最小化だけで実現でき、ジョブ側の `if` 条件を変更せずに安全に達成できる。
- `pull_request.closed` はマージ済み/クローズのみの共通イベントであり、`merged == true` 条件を維持することでマージ時処理だけを確実に残せる。

**プロセス上の改善点**:
- ステアリングのチェックボックスを実装と同時に更新することで、implementation-validator 指摘前に完了証跡を揃えるべきだった。

### 次回への改善提案
- 実装着手前に「このリポジトリで有効な検証コマンド（Ruby系/Node系）」を先に確認し、プロンプトとの差分を早期に tasklist に反映する。
- workflow 変更時はドキュメント例の YAML 断片も同時に更新し、運用手順との不整合を防止する。
