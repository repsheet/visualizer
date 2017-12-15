module Models exposing (..)

import RemoteData exposing (WebData)

type alias Model =
    { dashboard : WebData Dashboard
    }

initialModel : Model
initialModel =
    { dashboard = RemoteData.Loading
    }

type alias Dashboard =
    { blacklisted : String
    , whitelisted : String
    , marked      : String
    }
