require 'cgi'

# Writes a Markdown copy of every docs article next to its HTML page (/v6/eventColor.md),
# for AI agents. Mirrors the .md output of the v7 site: H1, a version blockquote, the
# article's Markdown source, then lists of child articles and demos for category pages.
#
# The source is read from the article's file and run through Liquid, but not kramdown, so
# {{ site.data... }} values are filled in. Done at write time for every article, since
# incremental builds only re-render changed pages. Links and images are made absolute. Links to other articles point at
# their .md copy. Code blocks are left untouched.

module MarkdownOutput
  ASSET_EXTENSIONS = /\.(png|jpe?g|gif|svg|webp|js|css|json|html|ics)$/i

  def self.eligible?(doc)
    doc.data['is_docs'] && doc.extname == '.md' && doc.data['slug'] != 'index'
  end

  # the article's Markdown source, without front matter, after Liquid
  def self.render_source(doc, payload)
    source = File.read(doc.path, **Jekyll::Utils.merged_file_read_opts(doc.site, {}))
    source = Regexp.last_match.post_match if source =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
    payload['page'] = doc.to_liquid
    template = doc.site.liquid_renderer.file(doc.path).parse(source)
    template.render!(payload, registers: { site: doc.site, page: payload['page'] })
  end

  def self.build(doc, body)
    site = doc.site
    parts = [
      "# #{doc.data['title']}",
      version_blockquote(doc, site),
    ]
    parts.push('Premium feature.') if doc.data['is_premium']
    parts.push(rewrite_urls(body.strip, doc)) unless body.strip.empty?
    parts.concat(child_sections(doc))
    parts.push(demos_section(doc)) if doc.data['demo_documents']
    parts.push(images_section(doc)) if doc.data['images']
    parts.join("\n\n") + "\n"
  end

  def self.version_blockquote(doc, site)
    version_id = doc.data['version']['id']
    web_url = site.config['url'] + doc.url
    v7_label = doc.data['v7_has_page'] ? 'Latest version (v7)' : 'Upgrading to v7'

    "> FullCalendar #{version_id} documentation, for an old release. Web version: #{web_url}\n>\n" \
    "> #{v7_label}: #{v7_markdown_url(doc.data['v7_url'], site)}"
  end

  # the v7 site publishes a .md copy of each docs page, and llms.txt for the docs index
  def self.v7_markdown_url(url, site)
    docs_url = "#{site.config['main_site_url']}/docs"

    if url == docs_url
      "#{docs_url}/llms.txt"
    elsif url.start_with?("#{docs_url}/")
      path, hash = url.split('#', 2)
      "#{path}.md" + (hash ? "##{hash}" : '')
    else
      url
    end
  end

  def self.child_sections(doc)
    sections = []

    for group in (doc.data['child_groups'] || [])
      title = if group['is_related'] then 'See Also' else group['title'] || 'Articles' end
      items = group['children'].map { |node| child_item(node['article']) }.compact
      sections.push("## #{title}\n\n#{items.join("\n")}") if items.any?
    end

    sections
  end

  def self.child_item(article)
    return nil if not article.respond_to?(:data) # unresolved slug, already reported by DocsIndexer

    description = description(article)
    link = "[#{article.data['title']}](#{article_url(article)})"
    description.empty? ? "- #{link}" : "- #{link} - #{description}"
  end

  def self.demos_section(doc)
    items = doc.data['demo_documents'].map do |demo|
      "- [#{demo.data['title']}](#{demo.site.config['url']}#{demo.url})"
    end
    "## Demos\n\n#{items.join("\n")}"
  end

  def self.images_section(doc)
    items = doc.data['images'].map do |image|
      "![#{image['caption']}](#{resolve_url(image['filename'], doc)})"
    end
    "## Images\n\n#{items.join("\n\n")}"
  end

  # a description from front matter, else the article's first paragraph as plain text.
  # A trailing sentence that introduces a list ("...the following packages:") is dropped
  def self.description(article)
    text = article.data['description'] || article.data['excerpt'].to_s
    text = CGI.unescapeHTML(text.gsub(/<[^>]+>/, '')).gsub(/\s+/, ' ').strip
    sentences = text.split(/(?<=[.!?])\s+/)
    sentences.pop if sentences.last&.end_with?(':')
    sentences.join(' ')
  end

  def self.article_url(article)
    url = article.site.config['url'] + article.url
    eligible?(article) ? "#{url}.md" : url
  end

  # rewrites Markdown link targets, <a href> and <img src> outside of fenced code and code spans.
  # <script src> is skipped: it only appears in code examples, some of them indented code blocks
  def self.rewrite_urls(markdown, doc)
    markdown.split(/(^[ \t]*```.*?^[ \t]*```[^\n]*$|`[^`\n]+`)/m).each_with_index.map do |chunk, i|
      next chunk if i.odd? # code block or code span

      chunk
        .gsub(/(\]\()([^)\s]+)/) { "#{$1}#{resolve_url($2, doc)}" }
        .gsub(/(<(?:a\s[^>]*?href|img\s[^>]*?src)=)(['"])(.*?)\2/) { "#{$1}#{$2}#{resolve_url($3, doc)}#{$2}" }
    end.join
  end

  def self.resolve_url(url, doc)
    site = doc.site
    site_url = site.config['url']
    return url if url.empty? || url.start_with?('#', '//') || url.match?(/^[a-z][a-z0-9+.-]*:/i)

    path, hash = url.split('#', 2)
    suffix = hash ? "##{hash}" : ''

    if path.start_with?('/')
      if (match = path.match(%r{^/(v\d+)/([^/?]+)$}))
        article_in_version(site, match[1], match[2], suffix) || site_url + url
      elsif path.match?(%r{^/(v\d+/?$|releases/|assets/)})
        site_url + url
      else
        site.config['main_site_url'] + url # pages that only exist on fullcalendar.io, like /pricing
      end
    elsif path.match?(ASSET_EXTENSIONS)
      "#{site_url}/#{doc.data['version']['id']}/#{path}#{suffix}"
    else
      article_in_version(site, doc.data['version']['id'], path, suffix) ||
        "#{site_url}/#{doc.data['version']['id']}/#{path}#{suffix}"
    end
  end

  def self.article_in_version(site, version_id, slug, suffix)
    version_obj = site.config['available_versions'].find { |v| v['id'] == version_id }
    article = version_obj && version_obj['doc_hash'] && version_obj['doc_hash'][slug]
    article && article_url(article) + suffix
  end
end

# advertises the .md copy from the HTML page, as <link rel='alternate'>
class MarkdownOutputUrls < Jekyll::Generator
  priority :lowest # after DocsIndexer sets is_docs

  def generate(site)
    for version_obj in site.config['available_versions']
      for doc in (version_obj['docs'] || [])
        doc.data['markdown_url'] = MarkdownOutput.article_url(doc) if MarkdownOutput.eligible?(doc)
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  payload = site.site_payload

  for version_obj in site.config['available_versions']
    for doc in (version_obj['docs'] || [])
      if MarkdownOutput.eligible?(doc)
        body = MarkdownOutput.render_source(doc, payload)
        File.write(File.join(site.dest, doc.url + '.md'), MarkdownOutput.build(doc, body))
      end
    end
  end
end
