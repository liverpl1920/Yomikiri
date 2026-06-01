---
description: 新機能を既存パターンに従って実装する（ステアリングファイル管理、テスト、PR作成まで含む）
---

// turbo-all

# 新機能追加ワークフロー

1. **ディレクトリとファイルの準備**
   - 機能名に基づき、`.steering/[YYYYMMDD]-[機能名]/` ディレクトリを作成する。
   - `requirements.md`, `design.md`, `tasklist.md` を作成する。（テンプレートは `.github/skills/steering/templates/` を参照）

2. **既存コードの調査**
   - `docs/` を読み、`grep_search` や `find_by_name` で既存の類似実装を調査する。

3. **計画の作成**
   - `requirements.md`, `design.md`, `tasklist.md` を具体的な内容で埋める。
   - `tasklist.md` にサブタスクを詳細に記載する。

4. **ブランチ作成**
   - `git checkout main`
   - `git pull origin main`
   - `git checkout -b feature/#[Issue番号]-[機能名]`

5. **実装ループ**
   - `tasklist.md` を読み込む。
   - 次の未完了タスクを選び、`tasklist.md` を `[ ]` から `[x]` に更新してから実装を開始する。
   - 実装が完了したら、次のタスクへ。
   - **全タスクが完了するまで繰り返す。**

6. **検証**
   - `bundle exec rspec`
   - `bundle exec rubocop`
   - エラーがあれば修正し、再度テストを実行する。

7. **コミット & プッシュ & PR作成**
   - `git add .`
   - `git commit -m "#[Issue番号] [作業内容]"`
   - `git push origin [ブランチ名]`
   - `gh pr create --title "#[Issue番号] [概要]" --body "..." --base main --head [ブランチ名]`
   - `gh pr checks --watch`

8. **振り返り**
   - `tasklist.md` の振り返りセクションを更新する。
