# 設計

## 対応方針

`books/_form.html.erb` のフォームタグ（`form_with`）に `autocomplete: 'off'` をHTMLオプションとして追加する。

これにより `<form autocomplete="off" ...>` が生成され、フォーム全体でパスワード管理ツールの誤認識を抑制できる。

## 変更ファイル

### `app/views/books/_form.html.erb`

`form_with` の呼び出し部分を下記のように変更する：

```erb
<%= form_with(model: book,
               multipart: true,
               html: { autocomplete: 'off' },
               data: {
                 controller: 'book-form'
               }) do |f| %>
```

## 補足

- 各フィールドの `autocomplete: 'off'` は既に設定されているが、フォームレベルでも明示することで拡張機能への対応を強化する。
- Railsの `form_with` は `html:` キーでフォームタグ自体にHTMLオプションを渡せる。
- テストへの影響はなし（HTMLの属性追加のみ）。
