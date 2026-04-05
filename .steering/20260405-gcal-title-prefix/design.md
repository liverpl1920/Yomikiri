# 設計: Googleカレンダーイベントタイトルへの接頭語追加

## 実装アプローチ

### 変更対象

`app/views/books/show.html.erb` のみ。JS側は変更不要。

### 変更内容

```erb
<%# 変更前 %>
<% gcal_description = "「#{@book.title}」の読書時間 (Yomikiri)" %>
<div ...
     data-google-calendar-title-value="<%= h(@book.title) %>"
     data-google-calendar-description-value="<%= h(gcal_description) %>">

<%# 変更後 %>
<% gcal_title = "【Yomikiri】#{@book.title}" %>
<% gcal_description = "【Yomikiri】「#{@book.title}」の読書時間" %>
<div ...
     data-google-calendar-title-value="<%= h(gcal_title) %>"
     data-google-calendar-description-value="<%= h(gcal_description) %>">
```

### 設計方針

- タイトルと説明文のフォーマットを `【Yomikiri】` 接頭語で統一
- ERBローカル変数でタイトルを組み立て、`h()` でXSSエスケープを維持
- 既存の `data-google-calendar-*-value` 属性の構造はそのまま維持
