\(args : { siteTitle : Text, pageTitle : Text, navHtml : Text, contentHtml : Text }) ->
''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${args.pageTitle} - ${args.siteTitle}</title>
    <link rel="stylesheet" href="/style.css">
</head>
<body>
    <nav>${args.navHtml}</nav>
    <main>
        <article>
            <h1>${args.pageTitle}</h1>
            ${args.contentHtml}
        </article>
    </main>
    <footer><p>&copy; ${args.siteTitle}</p></footer>
</body>
</html>
''
