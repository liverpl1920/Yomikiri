# 設計書

## アーキテクチャ概要

静的ファイルの置き換えと ERB テンプレートの修正のみ。Rails MVCの変更は不要。

```
public/icon.svg        ← SVGアイコン（ブラウザファビコン用）
public/icon.png        ← PNGアイコン（PWA用 512×512）
app/views/pwa/
  manifest.json.erb   ← PWAマニフェスト（theme_color等の修正）
```

## コンポーネント設計

### 1. SVG アイコン（public/icon.svg）

**責務**:
- ブラウザタブのファビコンとして表示
- SVGフォーマットで解像度に依存しない表示

**実装の要点**:
- 青背景（`#2563eb`）に角丸（rx=16）を付けたデザイン
- 白い「Y」テキストをセンタリング（font-size=72, text-anchor=middle）
- 100×100 の viewBox

### 2. PNG アイコン（public/icon.png）

**責務**:
- PWA マニフェストで参照される 512×512 アイコン
- ホーム画面追加時のアイコンとして使用

**実装の要点**:
- SVGと同等デザインの 512×512 PNG
- librsvg または ImageMagick などのツールで SVG から変換
- 変換ツールがない環境では Python の `cairosvg` を使用

### 3. PWA マニフェスト（app/views/pwa/manifest.json.erb）

**責務**:
- PWA としてのアプリ情報を提供

**実装の要点**:
- `theme_color`: `"#2563eb"`（ブランドカラー）
- `background_color`: `"#ffffff"`（スプラッシュスクリーン背景）
- `description`: `"積読を消化する技術 — 読了期限とノルマで読書を行動に変えるアプリ"`

## データフロー

### ファビコン表示フロー
```
1. ブラウザが /icon.svg または /icon.png をリクエスト
2. Rails の public/ ディレクトリから静的ファイルを返す
3. ブラウザタブにアイコンが表示される
```

### PWA インストールフロー
```
1. ブラウザが /manifest.json をリクエスト
2. manifest.json.erb がレンダリングされてJSONが返される 
3. PWA インストール時に icons[] の icon.png が使用される
```

## テスト戦略

この機能は静的ファイルの置き換えと ERB の軽微な修正のみのため、自動テストは新規追加しない。
既存のテストが引き続き通ることを確認する。

- `bundle exec rspec` - 既存テストの継続動作確認
- `bundle exec rubocop` - Ruby コードの修正なしのため問題なし

## ディレクトリ構造

```
public/
  icon.svg       ← 差し替え（青背景 + 白「Y」）
  icon.png       ← 差し替え（512×512）
app/views/pwa/
  manifest.json.erb  ← theme_color / background_color / description 修正
```

## 実装の順序

1. `public/icon.svg` を新デザインに差し替え
2. `public/icon.png` を新デザインに差し替え（SVGから変換）
3. `app/views/pwa/manifest.json.erb` を修正
4. テスト実行（既存テストが通ることを確認）
