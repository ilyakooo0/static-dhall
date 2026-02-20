# Hello World

This is my first blog post, built with [static-dhall](https://github.com/ilyakooo0/static-dhall).

## What is static-dhall?

A static site generator that uses:

- **Dhall** for type-safe site configuration
- **Markdown** for content authoring
- **Nix** for reproducible builds

## Getting Started

Edit `site.dhall` to configure your site, then run:

```bash
nix build
```

Your site will be in `./result/`.
