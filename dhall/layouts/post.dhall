\(args : { siteTitle : Text, postTitle : Text, dateStr : Text, tagsHtml : Text, navHtml : Text, contentHtml : Text }) ->
''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${args.postTitle} - ${args.siteTitle}</title>
    <link rel="stylesheet" href="/style.css">
</head>
<body>
    <nav>${args.navHtml}</nav>
    <main>
        <article>
            <header>
                <h1>${args.postTitle}</h1>
                <time>${args.dateStr}</time>
                ${args.tagsHtml}
            </header>
            ${args.contentHtml}
        </article>
    </main>
    <footer><p>&copy; ${args.siteTitle}</p></footer>
</body>
</html>
''
