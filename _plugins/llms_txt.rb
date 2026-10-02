require 'set'

# Writes an llms.txt index for each docs version (/v6/llms.txt), plus a root /llms.txt
# listing the versions. Follows llmstxt.org and the v7 site's /docs/llms.txt: an H1, a
# summary blockquote, then H2 sections of `- [title](url): description` links, each
# pointing at an article's .md copy (see markdown_output.rb).
#
# Sections come from the version's index.md tree: one per top-level group, listing each
# category and then the category's articles. Articles not reached that way go under
# "Optional".

module LlmsTxt
  def self.version_llms_url(site, version_obj)
    "#{site.config['url']}/#{version_obj['id']}/llms.txt"
  end

  def self.v7_llms_url(site)
    "#{site.config['main_site_url']}/docs/llms.txt"
  end

  def self.build_version(site, version_obj)
    version_id = version_obj['id']
    index_doc = version_obj['doc_hash']['index']
    seen = Set.new
    parts = [
      "# FullCalendar #{version_id}",
      "> Documentation for FullCalendar #{version_id}, an old release. The current version is v7, " \
        "documented at #{v7_llms_url(site)}. Every page linked here is Markdown.",
      upgrade_notes(site, version_obj),
    ]

    for group in (index_doc.data['own_child_groups'] || [])
      items = []

      for node in group['children']
        for article in [node['article'], *child_articles(node['article'])]
          if MarkdownOutput.eligible?(article) and seen.add?(article)
            items.push(item(article))
          end
        end
      end

      parts.push("## #{group['title'] || 'Articles'}", items.join("\n")) if items.any?
    end

    optional = version_obj['docs'].select do |doc|
      MarkdownOutput.eligible?(doc) and not seen.include?(doc)
    end

    if optional.any?
      parts.push('## Optional', optional.map { |doc| item(doc) }.join("\n"))
    end

    parts.join("\n\n") + "\n"
  end

  # a category's own articles, flattened. "related" articles are left to their own category
  def self.child_articles(article)
    return [] if not article.respond_to?(:data) # unresolved slug, already reported by DocsIndexer

    (article.data['own_child_groups'] || []).flat_map do |group|
      group['children'].map { |node| node['article'] }.select { |a| a.respond_to?(:data) }
    end
  end

  # the guides from this version up to v7, in order
  def self.upgrade_notes(site, version_obj)
    version_number = version_obj['id'].delete_prefix('v').to_i
    guides = []

    for later_version_obj in site.config['available_versions'].reverse
      for doc in (later_version_obj['docs'] || [])
        from_version = doc.data['slug'][/\Aupgrading-from-v(\d+)\z/, 1]
        guides.push(doc) if from_version and from_version.to_i >= version_number
      end
    end

    guides.sort_by! { |doc| doc.data['slug'][/\d+\z/].to_i }
    links = guides.map do |doc|
      "- [#{doc.data['title_for_nav'] || doc.data['title']}](#{MarkdownOutput.article_url(doc)})"
    end
    links.push("- [Upgrading from v6](#{site.config['v6_to_v7_url']}.md)")
    lead = links.length > 1 ? 'Upgrade guides, in order:' : 'Upgrade guide:'

    "Only use these docs for code that still runs FullCalendar #{version_obj['id']}. " \
      "Each major version since has breaking changes. #{lead}\n\n" + links.join("\n")
  end

  def self.item(article)
    description = MarkdownOutput.description(article)
    link = "[#{article.data['title']}](#{MarkdownOutput.article_url(article)})"
    description.empty? ? "- #{link}" : "- #{link}: #{description}"
  end

  def self.build_root(site)
    items = site.config['available_versions'].map do |version_obj|
      if version_obj['docs']
        "- [FullCalendar #{version_obj['id']}](#{version_llms_url(site, version_obj)})"
      elsif version_obj['aliased_to']
        "- FullCalendar #{version_obj['id']}: see #{version_obj['aliased_to']}, which is nearly API-compatible"
      end
    end

    [
      '# FullCalendar legacy documentation',
      '> Documentation for old releases of FullCalendar, v1 to v6. The current version is v7, ' \
        "documented at #{v7_llms_url(site)}. Use these docs only for code that still runs an old version.",
      '## Versions',
      items.compact.join("\n"),
    ].join("\n\n") + "\n"
  end
end

# the index page's "llms.txt" button
class LlmsTxtUrls < Jekyll::Generator
  priority :lowest # after DocsIndexer

  def generate(site)
    for version_obj in site.config['available_versions']
      index_doc = version_obj['doc_hash'] && version_obj['doc_hash']['index']
      index_doc.data['llms_url'] = "#{site.baseurl}/#{version_obj['id']}/llms.txt" if index_doc
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  for version_obj in site.config['available_versions']
    if version_obj['docs']
      path = File.join(site.dest, version_obj['id'], 'llms.txt')
      File.write(path, LlmsTxt.build_version(site, version_obj))
    end
  end

  File.write(File.join(site.dest, 'llms.txt'), LlmsTxt.build_root(site))
end
