module Main exposing (..)

import Routing
import Navigation exposing (Location)

import Models exposing (Model, initialModel)
import Msgs exposing (Msg)
import Update exposing (update)
import Subscriptions exposing (subscriptions)
import Commands exposing (fetchDashboard)
import View exposing (view)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            Routing.parseLocation location
    in
        ( initialModel currentRoute, fetchDashboard )

main : Program Never Model Msg
main =
    Navigation.program Msgs.OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
