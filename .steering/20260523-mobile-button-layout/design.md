# Design: スマホ画面でのボタンサイズ・レイアウトバランス改善

## 技術的分析

### 現状の問題点

#### 1. 共通ヘッダー（ゲスト状態）
- `_header.html.erb`: ロゴ (font-size 1.5rem, ~90px) + gap(1rem) + 「ログイン」ボタン(~100px) + gap(1rem) + 「無料で始める」ボタン(~150px)
- 320px画面では合計約340px以上となり横幅不足
- `header_footer.css` の `@media (max-width: 640px)` ではドロップダウンユーザー名非表示のみ対応。ゲストヘッダーボタンへの調整なし

#### 2. トップページヒーローCTA
- `top.css` で `@media (max-width: 480px)` では `flex-direction: column` 対応済み
- `top-header__nav .btn--lg` への調整あるが、実際の共通ヘッダーは `site-header__nav` クラスを使用

#### 3. 認証フォームボタン
- `.btn--full` で `width: 100%`, `padding: 0.75rem` → 適切だがフォントサイズがbaseのまま

### 実装方針

#### CSS変更のみで対応（HTMLの変更なし）

**`header_footer.css`** に以下のモバイル対応メディアクエリを追加:
```css
/* モバイル（430px以下）: ヘッダーボタンのサイズ調整 */
@media (max-width: 430px) {
  .site-header__nav .btn {
    padding: 0.45rem 0.75rem;
    font-size: var(--font-size-sm);  /* 0.875rem */
  }
  .site-header__logo {
    font-size: var(--font-size-xl); /* 1.5rem → 1.25rem */
  }
}

/* 極小モバイル（320px）: さらに調整 */
@media (max-width: 360px) {
  .site-header__nav {
    gap: var(--spacing-xs);  /* 1rem → 0.25rem */
  }
  .site-header__nav .btn {
    padding: 0.4rem 0.6rem;
  }
}
```

**`top.css`** のモバイルメディアクエリ修正:
- `top-header__nav` への参照を `site-header__nav` に修正（または `top.css` のルールを削除して `header_footer.css` に一本化）
- ヒーローCTAボタン（`.btn--lg`）の幅を430px以下で調整

**`auth.css`** への追加:
- モバイルでの `.auth-card` padding調整
- フォームボタン `.btn--full` のタップ領域確保

### ブレークポイント戦略
| ブレークポイント | 対象 |
|---|---|
| 480px以下 | 既存（top.css CTAスタック） |
| 430px以下 | ヘッダーボタン縮小 |
| 360px以下 | ヘッダー最小化（320px対応） |

### 修正ファイル
1. `app/assets/stylesheets/header_footer.css` - ゲストヘッダーボタンのモバイル対応
2. `app/assets/stylesheets/top.css` - top-header参照修正、ヒーローCTA追加調整
3. `app/assets/stylesheets/auth.css` - 認証フォームのモバイル調整
