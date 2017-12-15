module Main exposing (..)

import Html exposing (program)

import Models exposing (Model, initialModel, Dashboard)
import Msgs exposing (Msg)
import Update exposing (update)
import Subscriptions exposing (subscriptions)
import Commands exposing (fetchDashboard)
import View exposing (view)

init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchDashboard )

main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
