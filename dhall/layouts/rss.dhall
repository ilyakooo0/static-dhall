\(args : { siteTitle : Text, baseUrl : Text, description : Text, itemsXml : Text }) ->
''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
    <title>${args.siteTitle}</title>
    <link>${args.baseUrl}</link>
    <description>${args.description}</description>
    <atom:link href="${args.baseUrl}/rss.xml" rel="self" type="application/rss+xml"/>
    ${args.itemsXml}
</channel>
</rss>
''
