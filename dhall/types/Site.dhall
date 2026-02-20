let Page = ./Page.dhall

let Post = ./Post.dhall

let NavItem = ./NavItem.dhall

in  { Type =
        { title : Text
        , baseUrl : Text
        , author : Text
        , description : Text
        , nav : List NavItem
        , pages : List Page.Type
        , posts : List Post.Type
        }
    , default =
      { description = ""
      , nav = [] : List NavItem
      , pages = [] : List Page.Type
      , posts = [] : List Post.Type
      }
    }
