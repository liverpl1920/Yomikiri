# Copilot 行動指示書

このファイルはCopilotが**自律的に**作業を進めるための行動ルールを定義します。
作業のたびに必ずこのファイルを読み、ルールに従って実行してください。

---

## 1. 開発の全体フロー（必ず守る順序）

作業依頼を受けたら、以下の順序で進めること。ステップを飛ばしてはならない。

```
[1] 実装前確認     → docs/ の関連ドキュメントを読む
[2] ブランチ作成   → main から feature ブランチを切る
[3] 計画           → .steering/ にステアリングファイルを作成
[4] 実装           → tasklist.md に従って1タスクずつ実装・更新
[5] 検証           → RSpec + RuboCop を実行し全通過を確認
[6] コミット       → Issue番号付きメッセージでコミット
[7] push & PR      → リモートにプッシュしてPRを作成
[8] CI確認         → gh pr checks --watch で CI ステータスを確認
[9] 振り返り       → tasklist.md に振り返りを記載
```

---

## 2. 実装前の必須確認（[1]の詳細）

新しい作業を始める前に、**必ず以下を確認してから**実装を開始すること:

1. `docs/` 内の関連ドキュメントを読む（特に `architecture.md`, `development-guidelines.md`）
2. Grep で既存の類似実装を検索し、コードパターンを把握する
3. 既存パターンを理解してから実装開始

---

## 3. Gitワークフロー（フロー[2][6][7][8]に対応）

このセクションは以下のフローステップの詳細です：
- [2] ブランチ作成
- [6] コミット
- [7] push & PR
- [8] CI確認

### ブランチ作成（実装着手前に必ず実行）

```bash
git checkout main
git pull origin main
git checkout -b feature/#[Issue番号]-[作業内容の概要]
# 例: feature/#23-deadline-visualizer
```

- `main` ブランチで直接作業しない
- ブランチ名は必ず Issue番号を含める

### コミット前テスト（必ず実行、通過しなければコミットしない）

```bash
docker compose up -d db  # DBコンテナが起動していない場合
bundle exec rspec
bundle exec rubocop
```

- RSpec が全て通過し、RuboCop にエラーがないことを確認してからコミットする

### コミット

```bash
git commit -m "#[Issue番号] [作業内容の概要]"
# 例: #23 賞味期限ビジュアライザー機能の実装
```

- コミットメッセージには必ず Issue番号を含める
- 複数の Issue にまたがる変更は避け、Issue 単位で作業を完結させる

### push & PR作成（コミット完了後に自動実行）

```bash
# 1. ブランチをプッシュ
git push origin [ブランチ名]

# 2. PRを作成してCI監視まで一気に実行
gh pr create \
  --title "#[Issue番号] [作業内容の概要]" \
  --body $'## 概要\n[変更内容の説明]\n\n## 変更内容\n[変更ファイルと内容]\n\n## テスト結果\n[rspec / rubocop の結果]\n\nCloses #[Issue番号]' \
  --base main \
  --head [ブランチ名]

# 3. 作成したPRのCI監視を開始
gh pr checks --watch
```

**Note:** `gh pr checks --watch` は現在のブランチに紐づくPRを自動検出します。PR番号の指定は不要です。

### CI確認（PR作成後に自動実行）

上記の `gh pr checks --watch` コマンドが以下を自動実行します：

| CI結果 | 対応 |
|--------|------|
| 成功（pass） | 作業完了としてユーザーに報告する |
| 失敗（fail） | 失敗内容を分析し、修正コミット→プッシュ→再確認 |
| 実行中（pending） | `--watch` が自動的に完了まで待機するため追加操作は不要 |

### GitHub Project ステータス管理

- **実装着手前**: Issue を ["In Progress"](https://github.com/users/liverpl1920/projects/2/views/1) に移動する
- **PRマージ後**: Issue を "Done" に移動する

**CLI操作（参考）:**
```bash
# GitHub CLI v2.40以降でプロジェクトV2操作が可能
# 実際の運用では、ブラウザでの手動更新を推奨
gh issue edit [Issue番号] --add-project "Yomikiri" --project-column "In Progress"
```

**Note:** GitHub Projects V2のCLI操作は複雑なため、通常はブラウザで手動更新することを推奨します。

---

## 4. ステアリングファイル管理（フロー[3][9]に対応）

このセクションは以下のフローステップの詳細です：
- [3] 計画（ステアリングファイル作成）
- [9] 振り返り（tasklist.md更新）

### ファイル構成

作業ごとに `.steering/[YYYYMMDD]-[タスク名]/` を作成し、3ファイルを用意する:

```
.steering/20260404-deadline-visualizer/
  requirements.md   # 今回の要求内容
  design.md         # 実装アプローチ
  tasklist.md       # タスクリスト（進捗追跡）
```

### git管理方針

`.steering/` ディレクトリは**作業履歴として保持するため、git管理対象とする**。

- 各作業の計画・実装・振り返りの記録として価値がある
- 過去の実装パターンや意思決定の参照に有用
- チーム全体でナレッジを共有できる
- `.gitignore` に追加せず、PR時にもコミットする

### tasklist.md の運用（最重要）

- タスク完了のたびに `[ ]` → `[x]` にリアルタイム更新する
- **全タスクが `[x]` になるまで作業を継続する**（スキップ禁止）
- 技術的理由でスキップする場合のみ: `[x] ~~タスク名~~（理由: ...）`
- 振り返りの記載は全タスク完了後に行う

### スキルの使い分け

| タイミング | 使用スキル |
|-----------|-----------|
| ステアリングファイル作成時 | `steering` スキル（`.github/skills/steering/SKILL.md`）モード1 |
| 実装時 | `steering` スキル モード2 |
| 振り返り記載時 | `steering` スキル モード3 |
| コード実装時（規約確認） | `development-guidelines` スキル（`.github/skills/development-guidelines/SKILL.md`） |

---

## 5. ドキュメント作成時のルール

ドキュメント（`docs/` 配下）を新規作成する場合:

- **1ファイルずつ作成**し、必ずユーザーの承認を得てから次に進む
- 承認待ちの際は明確に伝える:
  ```
  「[ドキュメント名]の作成が完了しました。内容を確認してください。
  承認いただけたら次のドキュメントに進みます。」
  ```

---

## 6. 参照情報

### ディレクトリ構造

| パス | 用途 |
|------|------|
| `docs/` | プロジェクト全体の永続ドキュメント（「北極星」） |
| `docs/product-requirements.md` | プロダクト要求定義書 |
| `docs/functional-design.md` | 機能設計書 |
| `docs/architecture.md` | 技術仕様書 |
| `docs/repository-structure.md` | リポジトリ構造定義書 |
| `docs/development-guidelines.md` | 開発ガイドライン |
| `docs/glossary.md` | ユビキタス言語定義 |
| `docs/idea/` | 壁打ち・ブレインストーミングメモ（自由形式） |
| `.steering/` | 作業単位のドキュメント（作業ごとに新規作成、履歴として保持） |
| `.github/prompts/` | プロンプトファイル |
| `.github/skills/` | スキル定義ファイル |
| `.github/agents/` | エージェント定義ファイル |

### プロンプトファイル一覧

| ファイル | 用途 |
|---------|------|
| `add-feature.prompt.md` | 新機能追加（完全自動実行モード） |
| `setup-project.prompt.md` | 初回セットアップ（6つの永続ドキュメント作成） |
| `review-docs.prompt.md` | ドキュメントのレビュー |

### スキル一覧

| スキル | ファイル | 使用タイミング |
|--------|---------|--------------|
| steering | `.github/skills/steering/SKILL.md` | 作業計画・実装・振り返り時 |
| development-guidelines | `.github/skills/development-guidelines/SKILL.md` | コード実装時 |
| prd-writing | `.github/skills/prd-writing/SKILL.md` | PRD作成時 |
| functional-design | `.github/skills/functional-design/SKILL.md` | 機能設計書作成時 |
| architecture-design | `.github/skills/architecture-design/SKILL.md` | アーキテクチャ設計時 |
| repository-structure | `.github/skills/repository-structure/SKILL.md` | リポジトリ構造定義時 |
| glossary-creation | `.github/skills/glossary-creation/SKILL.md` | 用語集作成時 |

### エージェント一覧

| エージェント | ファイル | 用途 |
|------------|---------|------|
| doc-reviewer | `.github/agents/doc-reviewer.agent.md` | ドキュメントレビュー |
| implementation-validator | `.github/agents/implementation-validator.agent.md` | 実装品質の検証 |
