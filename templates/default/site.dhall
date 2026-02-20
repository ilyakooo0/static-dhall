let SD = ./.static-dhall/package.dhall

in  SD.Site::{
    , title = "My Site"
    , baseUrl = "https://example.com"
    , author = "Your Name"
    , description = "A site built with static-dhall"
    , nav =
      [ { label = "Home", url = "/" }
      , { label = "About", url = "/about" }
      ]
    , pages =
      [ SD.Page::{
        , title = "About"
        , slug = "about"
        , content = SD.Content.File "content/about.md"
        }
      ]
    , posts =
      [ SD.Post::{
        , title = "Hello World"
        , slug = "hello-world"
        , content = SD.Content.File "content/posts/hello-world.md"
        , date = { year = 2026, month = 1, day = 15 }
        , tags = [ "meta" ]
        }
      ]
    }
