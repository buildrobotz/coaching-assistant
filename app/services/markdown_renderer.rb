require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

# Renders Markdown to HTML with syntax highlighting
class MarkdownRenderer
  class HTMLWithRouge < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  def self.render(markdown_text)
    new.render(markdown_text)
  end

  def initialize
    @renderer = HTMLWithRouge.new(
      hard_wrap: true,
      link_attributes: { target: '_blank', rel: 'noopener noreferrer' }
    )

    @markdown = Redcarpet::Markdown.new(@renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      highlight: true,
      quote: true,
      footnotes: true,
      no_intra_emphasis: true,
      lax_spacing: true
    )
  end

  def render(markdown_text)
    return '' if markdown_text.blank?

    @markdown.render(markdown_text).html_safe
  end
end
