module Models exposing (..)

import RemoteData exposing (WebData)

type alias Model =
    { dashboard : WebData Dashboard
    }

initialModel : Model
initialModel =
    { dashboard = RemoteData.Loading
    }

type alias Actor =
    { address : String
    , reason  : String
    }

type alias Dashboard =
    { blacklist : List Actor
    , whitelist : List Actor
    , marklist  : List Actor
    }
