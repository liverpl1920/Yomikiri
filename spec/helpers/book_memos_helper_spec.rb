# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookMemosHelper, type: :helper do
  describe '#render_book_memo_content' do
    it '太字記法をHTMLタグに変換せず、そのままプレーンテキストとして出力する' do
      rendered = helper.render_book_memo_content('これは**重要**です')

      expect(rendered).to include('これは**重要**です')
      expect(rendered).not_to include('<strong>')
    end

    it '色記法をHTMLタグに変換せず、そのままプレーンテキストとして出力する' do
      rendered = helper.render_book_memo_content('[color=#ff0000]注意[/color]')

      expect(rendered).to include('[color=#ff0000]注意[/color]')
      expect(rendered).not_to include('<span')
    end

    it '許可外HTMLをエスケープする' do
      rendered = helper.render_book_memo_content('<script>alert(1)</script>')

      expect(rendered).not_to include('<script>')
      expect(rendered).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
    end
  end
end
