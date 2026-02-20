let Content = ./Content.dhall

in  { Date = ./Date.dhall
    , Content = Content
    , NavItem = ./NavItem.dhall
    , Page = ./Page.dhall
    , Post = ./Post.dhall
    , Site = ./Site.dhall
    , content =
      { File = \(path : Text) -> { tag = "File", value = path } : Content
      , Inline =
          \(markdown : Text) -> { tag = "Inline", value = markdown } : Content
      , DhallHtml =
          \(path : Text) -> { tag = "DhallHtml", value = path } : Content
      }
    }
