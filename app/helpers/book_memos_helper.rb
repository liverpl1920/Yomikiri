# frozen_string_literal: true

module BookMemosHelper
  BOLD_PATTERN = /\*\*(.+?)\*\*/m
  COLOR_PATTERN = /\[color=(#[0-9A-Fa-f]{6})\](.+?)\[\/color\]/m

  def render_book_memo_content(content)
    escaped = ERB::Util.html_escape(content.to_s)
    with_bold = escaped.gsub(BOLD_PATTERN, '<strong>\1</strong>')
    with_color = with_bold.gsub(COLOR_PATTERN) do
      "<span style=\"color: #{$1};\">#{$2}</span>"
    end

    simple_format(with_color, {}, sanitize: false)
  end
end
