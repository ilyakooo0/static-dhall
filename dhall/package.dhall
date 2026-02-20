let types = ./types/package.dhall

in  { Site = types.Site
    , Page = types.Page
    , Post = types.Post
    , Content = types.content
    , Date = types.Date
    , NavItem = types.NavItem
    , layouts = ./layouts/package.dhall
    }
