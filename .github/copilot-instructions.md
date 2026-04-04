# プロジェクトメモリ

## 技術スタック

### MVPリリース

| カテゴリ | 技術 |
|----------|------|
| フレームワーク | Ruby on Rails 7.2.x |
| データベース | PostgreSQL（Neon） |
| デプロイ先 | Render |
| 認証 | Devise |
| カレンダー連携 | Google Calendar URL生成（OAuth不要） |

### 本リリース（追加）

| カテゴリ | 技術 |
|----------|------|
| カレンダー連携 | omniauth-google-oauth2 / google-api-client |
| 書籍検索 | openBD API（APIキー不要） |
| メール送信 | ActionMailer + SendGrid |
| 定期実行 | GitHub Actions + rake task（JST換算で設定） |

### バックグラウンド処理

GitHub Actions（cron）でrake taskを実行:

- ノルマ再計算
- 期限イベント生成（期限3日前、読了など）
- 通知対象抽出

APIキー等はGitHub Secretsで管理。定期処理はJST基準（GitHub ActionsのcronはUTCのため換算すること）。

## スペック駆動開発の基本原則

### 基本フロー

1. **ドキュメント作成**: 永続ドキュメント(`docs/`)で「何を作るか」を定義
2. **作業計画**: ステアリングファイル(`.steering/`)で「今回何をするか」を計画
3. **実装**: tasklist.mdに従って実装し、進捗を随時更新
4. **検証**: テストと動作確認
5. **更新**: 必要に応じてドキュメント更新

### 重要なルール

#### ドキュメント作成時

**1ファイルずつ作成し、必ずユーザーの承認を得てから次に進む**

承認待ちの際は、明確に伝える:
```
「[ドキュメント名]の作成が完了しました。内容を確認してください。
承認いただけたら次のドキュメントに進みます。」
```

#### 実装前の確認

新しい実装を始める前に、必ず以下を確認:

1. `.github/copilot-instructions.md`を読む
2. 関連する永続ドキュメント(`docs/`)を読む
3. Grepで既存の類似実装を検索
4. 既存パターンを理解してから実装開始

#### ステアリングファイル管理

作業ごとに `.steering/[YYYYMMDD]-[タスク名]/` を作成:

- `requirements.md`: 今回の要求内容
- `design.md`: 実装アプローチ
- `tasklist.md`: 具体的なタスクリスト

命名規則: `20250115-add-user-profile` 形式

#### ステアリングファイルの管理

**作業計画・実装・検証時は `#skill-steering` スキルを参照してください。**

- **作業計画時**: `steering` スキル（`.github/skills/steering/SKILL.md`）のモード1(ステアリングファイル作成)を使用
- **実装時**: `steering` スキル（`.github/skills/steering/SKILL.md`）のモード2(実装とtasklist.md更新管理)を使用
- **検証時**: `steering` スキル（`.github/skills/steering/SKILL.md`）のモード3(振り返り)を使用

詳細な手順と更新管理のルールは `.github/skills/steering/SKILL.md` に定義されています。

## ディレクトリ構造

### 永続的ドキュメント(`docs/`)

アプリケーション全体の「何を作るか」「どう作るか」を定義:

#### 下書き・アイデア（`docs/ideas/`）
- 壁打ち・ブレインストーミングの成果物
- 技術調査メモ
- 自由形式（構造化は最小限）
- `setup-project`プロンプト実行時に自動的に読み込まれる

#### 正式版ドキュメント
- **product-requirements.md** - プロダクト要求定義書
- **functional-design.md** - 機能設計書
- **architecture.md** - 技術仕様書
- **repository-structure.md** - リポジトリ構造定義書
- **development-guidelines.md** - 開発ガイドライン
- **glossary.md** - ユビキタス言語定義

### 作業単位のドキュメント(`.steering/`)

特定の開発作業における「今回何をするか」を定義:

- `requirements.md`: 今回の作業の要求内容
- `design.md`: 変更内容の設計
- `tasklist.md`: タスクリスト

## 開発プロセス

### 初回セットアップ

1. このテンプレートを使用
2. `#setup-project.prompt.md` で永続的ドキュメント作成(対話的に6つ作成)
3. `#add-feature.prompt.md` で機能実装

### 日常的な使い方

**基本は普通に会話で依頼してください:**

```
# ドキュメントの編集
> PRDに新機能を追加してください
> architecture.mdのパフォーマンス要件を見直して
> glossary.mdに新しいドメイン用語を追加

# 機能追加(定型フローはプロンプト)
> @workspace #add-feature.prompt.md ユーザープロフィール編集

# 詳細レビュー(詳細なレポートが必要なとき)
> @workspace #review-docs.prompt.md docs/product-requirements.md
```

**ポイント**: スペック駆動開発の詳細を意識する必要はありません。各プロンプトファイル(`.github/prompts/`)が適切な動作を定義しています。

### Git操作のルール

**コミット前に必ずローカルでテストを実行する:**

```bash
# コミット前に必ず実行
docker compose up -d db  # DBコンテナが起動していない場合
bundle exec rspec
bundle exec rubocop
```

- RSpecが全て通過し、RuboCopにエラーがないことを確認してからコミットすること
- 上記が通過しない場合はコミットしない

**Issueごとにコミット&プッシュを行う:**

- プロジェクトのIssueごとに、関連する変更をまとめてコミットする
- 各Issue完了時には必ずGitHubにプッシュする
- コミットメッセージには対応するIssue番号を含める（例: `#123 ユーザープロフィール編集機能を実装`）
- 複数のIssueにまたがる変更は避け、Issue単位で作業を完結させる

**GitHub Projectのステータス管理:**

- **実装着手前**: 対象IssueをProjectボード（https://github.com/users/liverpl1920/projects/2/views/1）の **"In Progress"** に移動する
- **実装完了後**: PRマージ後に対象Issueを **"Done"** に移動する
- ステータス変更は `gh` CLIで行う:
  ```bash
  # 例: Issue #42 を "In Progress" に移動
  gh issue edit 42 --add-label "in-progress"
  ```
  > **Note**: ProjectのステータスフィールドはGraphQL APIが必要なため、CLIから直接変更できない場合はブラウザで手動更新すること

## プロンプトファイル一覧 (`.github/prompts/`)

### コマンド系プロンプト
- `setup-project.prompt.md` - 初回セットアップ (6つの永続ドキュメント作成)
- `add-feature.prompt.md` - 新機能追加 (完全自動実行モード)
- `review-docs.prompt.md` - ドキュメントのレビュー

## エージェント一覧 (`.github/agents/`)

エージェントはスキルと同様に独立した定義ファイルとして管理します。

- `doc-reviewer.md` - ドキュメントレビューエージェント
- `implementation-validator.md` - 実装検証エージェント

## スキル一覧 (`.github/skills/`)

スキルはAgentが自動的に必要に応じてSKILL.mdを読み込みます（上記`<skills>`ブロック参照）。

- `steering/SKILL.md` - ステアリングファイル管理
- `prd-writing/SKILL.md` - PRD作成ガイド
- `functional-design/SKILL.md` - 機能設計書作成ガイド
- `architecture-design/SKILL.md` - アーキテクチャ設計書作成ガイド
- `repository-structure/SKILL.md` - リポジトリ構造定義書作成ガイド
- `development-guidelines/SKILL.md` - 開発ガイドライン作成ガイド
- `glossary-creation/SKILL.md` - 用語集作成ガイド

## ドキュメント管理の原則

### 永続的ドキュメント(`docs/`)

- 基本設計を記述
- 頻繁に更新されない
- プロジェクト全体の「北極星」

### 作業単位のドキュメント(`.steering/`)

- 特定の作業に特化
- 作業ごとに新規作成
- 履歴として保持

<skills>
Here is a list of skills that contain domain specific knowledge on a variety of topics.
Each skill comes with a description of the topic and a file path that contains the detailed instructions.
When a user asks you to perform a task that falls within the domain of a skill, use the read_file tool to acquire the full instructions from the file path.

<skill>
<name>steering</name>
<description>作業指示毎の作業計画、タスクリストをドキュメントに記録するためのスキル。ユーザーからの指示をトリガーとした作業計画時、実装時、検証時に読み込む。</description>
<file>.github/skills/steering/SKILL.md</file>
</skill>

<skill>
<name>prd-writing</name>
<description>プロダクト要求定義書(PRD)を作成するための詳細ガイドとテンプレート。PRD作成時にのみ使用。</description>
<file>.github/skills/prd-writing/SKILL.md</file>
</skill>

<skill>
<name>functional-design</name>
<description>機能設計書を作成するための詳細ガイドとテンプレート。機能設計書作成時にのみ使用。</description>
<file>.github/skills/functional-design/SKILL.md</file>
</skill>

<skill>
<name>architecture-design</name>
<description>アーキテクチャ設計書を作成するための詳細ガイドとテンプレート。アーキテクチャ設計時にのみ使用。</description>
<file>.github/skills/architecture-design/SKILL.md</file>
</skill>

<skill>
<name>repository-structure</name>
<description>リポジトリ構造定義書を作成するための詳細ガイドとテンプレート。リポジトリ構造定義時にのみ使用。</description>
<file>.github/skills/repository-structure/SKILL.md</file>
</skill>

<skill>
<name>development-guidelines</name>
<description>チーム全体で統一された開発プロセスとコーディング規約を確立するための包括的なガイドとテンプレート。開発ガイドライン作成時、コード実装時に使用する。</description>
<file>.github/skills/development-guidelines/SKILL.md</file>
</skill>

<skill>
<name>glossary-creation</name>
<description>用語集を作成するための詳細ガイドとテンプレート。用語集作成時にのみ使用。</description>
<file>.github/skills/glossary-creation/SKILL.md</file>
</skill>
</skills>
