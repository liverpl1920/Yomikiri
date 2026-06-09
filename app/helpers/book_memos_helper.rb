# frozen_string_literal: true

module BookMemosHelper
  def render_book_memo_content(content)
    simple_format(ERB::Util.html_escape(content.to_s), {}, sanitize: false)
  end
end
