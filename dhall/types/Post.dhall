let Content = ./Content.dhall

let DateType = ./Date.dhall

in  { Type =
        { title : Text
        , slug : Text
        , content : Content
        , date : DateType
        , tags : List Text
        , draft : Bool
        }
    , default = { tags = [] : List Text, draft = False }
    }
