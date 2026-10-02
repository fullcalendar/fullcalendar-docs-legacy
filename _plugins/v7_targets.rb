require 'set'

# Computes, for every page, the canonical URL and the link for the old-version banner.
#
# Legacy docs pages point to their v7 successor, resolved by walking the transitions
# (v1→v3→v4→v5→v6→v7) the same way the 301 redirects on fullcalendar.io do. The data in
# _data/docs-redirects is copied from fullcalendar-site/site/docs-redirects. Keep it in sync.
#
# Sets on each page:
#   canonical_url - absolute URL for <link rel='canonical'>
#   in_sitemap    - whether the page is its own canonical, so belongs in sitemap.xml
#   v7_url        - docs pages only. Where the banner links
#   v7_has_page   - docs pages only. Whether v7_url is a successor page rather than the upgrade guide
class V7Targets < Jekyll::Generator
  priority :low # after DocsIndexer

  def generate(site)
    redirects = site.data['docs-redirects']
    @inventories = {}
    @transitions = {}

    for inventory in redirects['inventories'].values
      @inventories[inventory['version']] = Set.new(inventory['articles'])
    end

    for transition in redirects['transitions'].values
      @transitions[transition['from']] = transition
    end

    @current_version = @transitions.values.map { |transition| transition['to'] }.max
    @main_site_url = site.config['main_site_url']
    @site_url = site.config['url']

    for version_obj in site.config['available_versions']
      if version_obj['collection']
        version = version_obj['id'].delete_prefix('v').to_i

        for doc in site.collections[version_obj['collection']].docs
          assign_docs_targets(doc, version, site)
        end
      end
    end

    for page in site.pages
      if page.output_ext == '.html'
        page.data['canonical_url'] = self_url(page.url)
        page.data['in_sitemap'] = true
      end
    end
  end

  def assign_docs_targets(doc, version, site)
    slug = doc.data['slug']
    canonical_url = nil
    v7_url = nil

    if slug == 'index'
      canonical_url = v7_url = "#{@main_site_url}/docs"
    elsif @inventories[version].include?(slug)
      target = resolve(version, slug)

      if target[:url]
        v7_url = absolute_main_site_url(target[:url])
        canonical_url = v7_url.split('#').first if v7_url.start_with?("#{@main_site_url}/")
      elsif target[:version] != version # retired after a newer legacy version
        canonical_url = self_url("/v#{target[:version]}/#{target[:slug]}")
      end
    elsif not slug.start_with?('debug-')
      Jekyll.logger.warn 'V7Targets:', "v#{version} #{slug} is not in the docs-redirects inventory"
    end

    doc.data['canonical_url'] = canonical_url || self_url(doc.url)
    doc.data['in_sitemap'] = canonical_url.nil? && !slug.start_with?('debug-')
    doc.data['v7_url'] = v7_url || site.config['v6_to_v7_url']
    doc.data['v7_has_page'] = !v7_url.nil?
  end

  # Returns { url: } for a successor URL, or { version:, slug: } for the newest legacy page
  # when the article was retired.
  def resolve(version, slug)
    while version != @current_version
      transition = @transitions.fetch(version)
      replacement = transition['replaced'][slug]

      if transition['retired'].include?(slug)
        return { version: version, slug: slug }
      elsif replacement.is_a?(String)
        slug = replacement
      elsif replacement
        return { url: replacement['url'] } if not replacement['slug']
        slug = replacement['slug']
      elsif transition['to'] != @current_version and not @inventories[transition['to']].include?(slug)
        raise "v#{version} article #{slug} is not classified by its transition"
      end

      version = transition['to']
    end

    { url: "/docs/#{slug}" }
  end

  def absolute_main_site_url(url)
    url.start_with?('/') ? @main_site_url + url : url
  end

  # the served URL, which has no trailing slash (wrangler's drop-trailing-slash)
  def self_url(url)
    @site_url + (url == '/' ? url : url.chomp('/'))
  end
end
