#!/usr/bin/env bash
set -euo pipefail

# Inputs (set by Nix derivation):
#   $src        - user's site source directory
#   $out        - Nix output path
#   $layoutsDir - path to our default layouts
#   $themeDir   - path to our theme directory

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$out"

# --- Step 1: Generate manifest from site.dhall ---
echo "Generating site manifest..."
manifest="$tmpdir/manifest.json"
dhall-to-json --file "$src/site.dhall" > "$manifest"

# --- Step 2: Extract site metadata ---
siteTitle=$(jq -r '.title' "$manifest")
baseUrl=$(jq -r '.baseUrl' "$manifest")
description=$(jq -r '.description' "$manifest")

# --- Step 3: Render nav HTML ---
navHtmlFile="$tmpdir/nav.txt"
jq -r '.nav[] | "<a href=\"\(.url)\">\(.label)</a>"' "$manifest" \
  | tr '\n' ' ' > "$navHtmlFile"

# --- Helper: render content ---
render_content() {
  local content_json="$1"
  local content_type content_value
  content_type=$(echo "$content_json" | jq -r '.tag')
  content_value=$(echo "$content_json" | jq -r '.value')

  case "$content_type" in
    File)
      pandoc "$src/$content_value" -f markdown -t html --no-highlight
      ;;
    Inline)
      echo "$content_value" | pandoc -f markdown -t html --no-highlight
      ;;
    DhallHtml)
      dhall text --file "$src/$content_value"
      ;;
    *)
      echo "Unknown content type: $content_type" >&2
      exit 1
      ;;
  esac
}

# --- Helper: format date ---
format_date() {
  local date_json="$1"
  local year month day
  year=$(echo "$date_json" | jq -r '.year')
  month=$(echo "$date_json" | jq -r '.month')
  day=$(echo "$date_json" | jq -r '.day')
  printf "%04d-%02d-%02d" "$year" "$month" "$day"
}

# --- Helper: render tags HTML ---
render_tags() {
  local tags_json="$1"
  local count
  count=$(echo "$tags_json" | jq -r 'length')
  if [ "$count" -eq 0 ]; then
    echo ""
    return
  fi
  local result='<ul class="tags">'
  while IFS= read -r tag; do
    result+="<li>$tag</li>"
  done < <(echo "$tags_json" | jq -r '.[]')
  result+='</ul>'
  echo "$result"
}

# --- Helper: apply a Dhall layout ---
apply_layout() {
  local layout_file="$1"
  local args_file="$2"
  dhall text <<DHALL
let layout = $layout_file
let args = $args_file
in layout args
DHALL
}

# --- Step 4: Build pages ---
echo "Building pages..."
page_count=$(jq -r '.pages | length' "$manifest")
for ((i = 0; i < page_count; i++)); do
  page_json=$(jq -r ".pages[$i]" "$manifest")
  pageTitle=$(echo "$page_json" | jq -r '.title')
  pageSlug=$(echo "$page_json" | jq -r '.slug')
  content_json=$(echo "$page_json" | jq -r '.content')

  echo "  Page: $pageTitle ($pageSlug)"

  contentFile="$tmpdir/content.txt"
  render_content "$content_json" > "$contentFile"

  echo -n "$siteTitle" > "$tmpdir/siteTitle.txt"
  echo -n "$pageTitle" > "$tmpdir/pageTitle.txt"

  argsFile="$tmpdir/args.dhall"
  cat > "$argsFile" <<DHALL
{ siteTitle = $tmpdir/siteTitle.txt as Text
, pageTitle = $tmpdir/pageTitle.txt as Text
, navHtml = $navHtmlFile as Text
, contentHtml = $contentFile as Text
}
DHALL

  outDir="$out/$pageSlug"
  mkdir -p "$outDir"
  apply_layout "$layoutsDir/page.dhall" "$argsFile" > "$outDir/index.html"
done

# --- Step 5: Build posts ---
echo "Building posts..."
post_count=$(jq -r '.posts | length' "$manifest")
postsHtmlFile="$tmpdir/posts_list.txt"
rssItemsFile="$tmpdir/rss_items.txt"
> "$postsHtmlFile"
> "$rssItemsFile"

for ((i = 0; i < post_count; i++)); do
  post_json=$(jq -r ".posts[$i]" "$manifest")
  draft=$(echo "$post_json" | jq -r '.draft')

  if [ "$draft" = "true" ]; then
    continue
  fi

  postTitle=$(echo "$post_json" | jq -r '.title')
  postSlug=$(echo "$post_json" | jq -r '.slug')
  content_json=$(echo "$post_json" | jq -r '.content')
  date_json=$(echo "$post_json" | jq -r '.date')
  tags_json=$(echo "$post_json" | jq -r '.tags')
  dateStr=$(format_date "$date_json")

  echo "  Post: $postTitle ($postSlug)"

  contentFile="$tmpdir/content.txt"
  render_content "$content_json" > "$contentFile"

  tagsFile="$tmpdir/tags.txt"
  render_tags "$tags_json" > "$tagsFile"

  echo -n "$siteTitle" > "$tmpdir/siteTitle.txt"
  echo -n "$postTitle" > "$tmpdir/postTitle.txt"
  echo -n "$dateStr" > "$tmpdir/dateStr.txt"

  argsFile="$tmpdir/args.dhall"
  cat > "$argsFile" <<DHALL
{ siteTitle = $tmpdir/siteTitle.txt as Text
, postTitle = $tmpdir/postTitle.txt as Text
, dateStr = $tmpdir/dateStr.txt as Text
, tagsHtml = $tagsFile as Text
, navHtml = $navHtmlFile as Text
, contentHtml = $contentFile as Text
}
DHALL

  outDir="$out/posts/$postSlug"
  mkdir -p "$outDir"
  apply_layout "$layoutsDir/post.dhall" "$argsFile" > "$outDir/index.html"

  cat >> "$postsHtmlFile" <<HTML
<article class="post-summary">
    <h2><a href="/posts/$postSlug/">$postTitle</a></h2>
    <time>$dateStr</time>
</article>
HTML

  contentForRss=$(cat "$contentFile")
  cat >> "$rssItemsFile" <<XML
<item>
    <title>$postTitle</title>
    <link>$baseUrl/posts/$postSlug/</link>
    <guid>$baseUrl/posts/$postSlug/</guid>
    <pubDate>$dateStr</pubDate>
    <description><![CDATA[$contentForRss]]></description>
</item>
XML
done

# --- Step 6: Build index page ---
echo "Building index page..."
echo -n "$siteTitle" > "$tmpdir/siteTitle.txt"
echo -n "$description" > "$tmpdir/description.txt"

argsFile="$tmpdir/args.dhall"
cat > "$argsFile" <<DHALL
{ siteTitle = $tmpdir/siteTitle.txt as Text
, description = $tmpdir/description.txt as Text
, navHtml = $navHtmlFile as Text
, postsHtml = $postsHtmlFile as Text
}
DHALL

apply_layout "$layoutsDir/index.dhall" "$argsFile" > "$out/index.html"

# --- Step 7: Build RSS feed ---
echo "Building RSS feed..."
echo -n "$baseUrl" > "$tmpdir/baseUrl.txt"

argsFile="$tmpdir/args.dhall"
cat > "$argsFile" <<DHALL
{ siteTitle = $tmpdir/siteTitle.txt as Text
, baseUrl = $tmpdir/baseUrl.txt as Text
, description = $tmpdir/description.txt as Text
, itemsXml = $rssItemsFile as Text
}
DHALL

apply_layout "$layoutsDir/rss.dhall" "$argsFile" > "$out/rss.xml"

# --- Step 8: Copy theme ---
echo "Copying theme..."
cp "$themeDir/style.css" "$out/style.css"

echo "Build complete!"
