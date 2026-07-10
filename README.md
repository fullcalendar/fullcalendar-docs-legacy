
# FullCalendar Legacy Docs

This repo contains static legacy documentation and release assets.

Documentation articles are found in directories like `_docs-*`.

Made with [Jekyll](https://jekyllrb.com/).


## Installation

Prerequisites:

- Node.js 22.16 or later
- pnpm 10.28
- Ruby 3.4
- [RubyGems Bundler](https://bundler.io/)

Run:

```sh
# If you use RVM, select the Ruby version declared by .ruby-version:
rvm use .

bundle install
pnpm install
```

## NPM Scripts

```sh
# watch & serve while developing
pnpm dev

# build into _site directory
pnpm build
```

The development site is served at Jekyll's default port [http://localhost:4000](http://localhost:4000).


## Deployment

The generated `_site` directory is deployed as static assets on Cloudflare Workers.
Workers Builds should use these commands:

```sh
# build command
pnpm cloudflare:build

# production deploy command
pnpm cloudflare:deploy

# non-production branch deploy command
pnpm cloudflare:preview
```

Set `PNPM_VERSION` to `10.28.0` in the Workers Builds environment. Ruby and
Node.js are selected from `.ruby-version` and `.node-version`.


## Reporting Problems

See a problem with the docs? Create a ticket in the [main dev repo's issue tracker](https://github.com/fullcalendar/fullcalendar/issues). All docs-related bugs have the [docs label](https://github.com/fullcalendar/fullcalendar/issues?q=is%3Aopen+is%3Aissue+label%3ADocs).


## Contributing

To make edits to the documentation please submit a [Pull Request](https://help.github.com/articles/creating-a-pull-request/) against the `main` branch of this repo.

Ensure linting passes before submitting PRs:

```sh
pnpm lint
```
