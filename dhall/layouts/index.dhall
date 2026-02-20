\(args : { siteTitle : Text, description : Text, navHtml : Text, postsHtml : Text }) ->
''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${args.siteTitle}</title>
    <link rel="stylesheet" href="/style.css">
    <link rel="alternate" type="application/rss+xml" title="${args.siteTitle}" href="/rss.xml">
</head>
<body>
    <nav>${args.navHtml}</nav>
    <main>
        <header class="site-header">
            <h1>${args.siteTitle}</h1>
            <p>${args.description}</p>
        </header>
        <section class="post-list">
            ${args.postsHtml}
        </section>
    </main>
    <footer><p>&copy; ${args.siteTitle}</p></footer>
</body>
</html>
''
