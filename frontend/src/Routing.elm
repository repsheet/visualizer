module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (Route(..))
import UrlParser exposing (..)

matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map DashboardRoute top
        , map BlacklistRoute (s "blacklist")
        , map WhitelistRoute (s "whitelist")
        , map MarklistRoute  (s "marklist")
        , map ActorRoute     (s "actors" </> string)
        ]

parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route
        Nothing ->
            NotFoundRoute
