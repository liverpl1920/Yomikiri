# Codex Project Instructions

このファイルは、Codex がこのリポジトリで作業する際に必ず参照するプロジェクト設定です。
GitHub Copilot 用の `.github/copilot-instructions.md` と `.github/skills/` の内容を、Codex で同等に運用できる形に整理しています。

## 基本方針

- 回答と作業ログは日本語を基本とする。
- 実装前に `docs/` の関連ドキュメント、特に `docs/architecture.md` と `docs/development-guidelines.md` を確認する。
- `rg` で既存の類似実装を検索し、既存パターン、命名、責務分割に合わせて実装する。
- 既存の未コミット変更はユーザーの作業として扱い、明示指示なく戻さない。
- 変更範囲は依頼内容に必要な最小範囲に保つ。

## 参照優先度

1. ユーザーの最新指示
2. この `AGENTS.md`
3. `docs/` 配下の永続ドキュメント
4. `.steering/` 配下の該当作業ドキュメント
5. `.github/skills/` 配下のスキル定義
6. `.github/copilot-instructions.md` と `.github/prompts/`

矛盾がある場合は、より上位の指示を優先し、必要なら理由を短く説明する。

## プロジェクト概要

- Rails アプリケーション。
- 主要ドキュメント:
  - `docs/product-requirements.md`
  - `docs/functional-design.md`
  - `docs/architecture.md`
  - `docs/repository-structure.md`
  - `docs/development-guidelines.md`
  - `docs/development-workflow.md`
  - `docs/glossary.md`
- 作業単位の記録は `.steering/[YYYYMMDD]-[タスク名]/` に保存する。

## Codex での標準ワークフロー

依頼が実装・修正・調査を含む場合は、原則として次の順序で進める。

1. 関連ドキュメントを読む。
2. `rg` で既存実装とテストを調査する。
3. 必要に応じて `.steering/` に `requirements.md`、`design.md`、`tasklist.md` を作成または更新する。
4. `tasklist.md` がある作業では、タスク完了ごとに `[ ]` を `[x]` に更新する。
5. 既存パターンに沿って実装する。
6. 変更内容に見合うテストを追加または更新する。
7. RSpec と RuboCop を実行し、結果を報告する。
8. 作業完了後、必要に応じて `tasklist.md` に振り返りを記録する。

ユーザーが「計画だけ」「調査だけ」「レビューだけ」と指定した場合は、実装やファイル編集に進まない。

## ステアリングファイル運用

`.github/skills/steering/SKILL.md` を Codex でも作業計画・実装管理・振り返りの参照元として使う。

作業ごとに必要なら以下を作成する。

```text
.steering/[YYYYMMDD]-[タスク名]/
  requirements.md
  design.md
  tasklist.md
```

運用ルール:

- `.steering/` は git 管理対象として保持する。
- `tasklist.md` が存在する場合、進捗管理の正式な記録は `tasklist.md` とする。
- 未完了タスクを残したまま完了報告しない。
- 技術的理由で不要になったタスクのみ、理由を明記して完了扱いにできる。
- 実装方針が大きく変わった場合は `design.md` も更新する。

## スキル相当の参照

GitHub Copilot の skill は Codex の自動 skill としては直接ロードされないため、必要に応じて以下のファイルを読んで同等のルールとして扱う。

| 用途 | 参照ファイル |
| --- | --- |
| 作業計画・進捗管理・振り返り | `.github/skills/steering/SKILL.md` |
| 実装規約・開発プロセス | `.github/skills/development-guidelines/SKILL.md` |
| PRD 作成 | `.github/skills/prd-writing/SKILL.md` |
| 機能設計書作成 | `.github/skills/functional-design/SKILL.md` |
| アーキテクチャ設計 | `.github/skills/architecture-design/SKILL.md` |
| リポジトリ構造定義 | `.github/skills/repository-structure/SKILL.md` |
| 用語集作成 | `.github/skills/glossary-creation/SKILL.md` |

各 skill が `guide.md`、`template.md`、`templates/` を参照している場合は、必要なファイルだけを読む。

## プロンプト相当の参照

`.github/prompts/` は Copilot 専用だが、Codex でもワークフロー定義として参照する。

| 用途 | 参照ファイル |
| --- | --- |
| 新機能追加 | `.github/prompts/add-feature.prompt.md` |
| 初回セットアップ | `.github/prompts/setup-project.prompt.md` |
| ドキュメントレビュー | `.github/prompts/review-docs.prompt.md` |

ただし、プロンプト内に `npm test`、`src/` など Rails 構成と合わない記述がある場合は、現在のリポジトリ構成と `docs/development-guidelines.md` を優先する。

## レビュー・検証エージェント相当

Copilot の agent 定義は Codex のサブエージェントとしては直接使えないため、必要に応じてレビュー観点として読む。

- 実装品質検証: `.github/agents/implementation-validator.agent.md`
- ドキュメントレビュー: `.github/agents/doc-reviewer.agent.md`

レビュー依頼を受けた場合は、バグ、仕様不一致、テスト不足、セキュリティ、保守性の問題を優先し、ファイルと行番号を添えて報告する。

## Git ワークフロー

Issue 起点の作業では `docs/development-workflow.md` と `.github/copilot-instructions.md` を参照する。

- `main` に直接コミットしない。
- ブランチ名は `feature/#{Issue番号}-{短い説明}` を基本とする。
- コミットメッセージは Issue 番号を含める。
- PR 作成時は `.github/pull_request_template.md` を確認する。
- push、PR 作成、Project ステータス変更は、ユーザーの依頼または明確な合意がある場合に実行する。

## 検証コマンド

変更内容に応じて以下を実行する。

```bash
docker compose up -d db
bundle exec rspec
bundle exec rubocop
```

必要に応じて以下も使う。

```bash
bundle exec brakeman --no-pager
bundle-audit check --update
```

ローカル環境や依存サービスの問題で実行できない場合は、実行できなかった理由と未検証範囲を報告する。

## Rails 実装規約

詳細は `docs/development-guidelines.md` を優先する。

- Ruby/Rails は RuboCop の規約に従う。
- Ruby は 2 スペースインデント、メソッドと変数は `snake_case`、クラスは `UpperCamelCase`。
- メソッドは単一責務を意識し、複雑な分岐はガード節で浅くする。
- ERB は Rails のヘルパーとパーシャルを優先し、生 HTML のリンクやフォームを増やさない。
- JavaScript は Stimulus を優先し、グローバル関数や手書き AJAX を増やしすぎない。
- CSS は BEM を基本とし、Tailwind は導入しない。
- ユーザー入力、認可、ファイルアップロード、外部 API、環境変数を扱う変更はセキュリティ観点を必ず確認する。

## ドキュメント作成ルール

`docs/` 配下の永続ドキュメントを新規作成または大きく更新する場合:

- 既存ドキュメントの構造と用語を優先する。
- 1ファイルずつ作成・更新し、ユーザーが確認しやすい単位で報告する。
- プロダクト用語は `docs/glossary.md` と整合させる。

## 完了報告

完了時は以下を簡潔に報告する。

- 変更したファイル
- 主要な変更内容
- 実行した検証コマンドと結果
- 実行できなかった検証があれば理由
