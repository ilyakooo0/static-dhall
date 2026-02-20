let Content = ./Content.dhall

in  { Type = { title : Text, slug : Text, content : Content }
    , default = {=}
    }
