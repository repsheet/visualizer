module Models exposing (..)

import RemoteData exposing (WebData)

type alias Model =
    { dashboard : WebData Dashboard
    , route : Route
    }

initialModel : Route -> Model
initialModel route =
    { dashboard = RemoteData.Loading
    , route = route
    }

type alias Address =
    String

type alias Actor =
    { address : Address
    , reason  : String
    }

type alias Dashboard =
    { blacklist : List Actor
    , whitelist : List Actor
    , marklist  : List Actor
    }

type Route
    = DashboardRoute
    | BlacklistRoute
    | WhitelistRoute
    | MarklistRoute
    | ActorRoute Address
    | NotFoundRoute
