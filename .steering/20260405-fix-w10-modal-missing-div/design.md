# 設計書

## アーキテクチャ概要

Railsの ERB テンプレートにおける HTML タグの欠落修正。ロジックの変更は一切なく、純粋な HTML 構造の修正のみ。

```
show.html.erb (修正前)
  └─ .modal-overlay (W-10)
       ├─ .modal
       │    ├─ form_with
       │    │    └─ <% end %>
       │    └─ [</div> 欠落] ← .modal の閉じタグ
       └─ [</div> 欠落] ← .modal-overlay の閉じタグ
            └─ .modal-overlay.celebration-modal-overlay (W-13) ← 誤ってネスト

show.html.erb (修正後)
  ├─ .modal-overlay (W-10)
  │    └─ .modal
  │         └─ form_with
  │              └─ <% end %>
  │         └─ </div> ← .modal の閉じタグ
  │    └─ </div> ← .modal-overlay の閉じタグ
  └─ .modal-overlay.celebration-modal-overlay (W-13) ← 正しく独立
```

## コンポーネント設計

### 1. app/views/books/show.html.erb

**責務**:
- 書籍詳細ページのHTMLを正しい構造で提供する
- W-10（期限延長モーダル）と W-13（読了お祝いモーダル）が独立した DOM 要素として存在する

**修正の要点**:
- `<% end %>` (form_with 終了) と `<%# 読了お祝いモーダル (W-13) %>` の間に `    </div>` と `  </div>` を追加する
- インデント構造を合わせること

## データフロー

### 修正箇所の特定

```
1. show.html.erb を開く
2. <%# 期限延長モーダル (W-10) %> のブロックを探す
3. form_with の <% end %> の直後を確認
4. </div></div> を2行追加する
```

## エラーハンドリング戦略

なし（HTMLタグの追加のみ）
