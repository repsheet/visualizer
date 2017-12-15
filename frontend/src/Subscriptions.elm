module Subscriptions exposing (..)

import Models exposing (Model)
import Msgs exposing (Msg)

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
