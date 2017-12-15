module Commands exposing (..)

import Http
import RemoteData
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)

import Models exposing (Dashboard, Actor)
import Msgs exposing (Msg)

fetchDashboard : Cmd Msg
fetchDashboard =
    Http.get fetchDashboardUrl dashboardDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchDashboard

fetchDashboardUrl : String
fetchDashboardUrl =
    "http://localhost:4000/dashboard"

actorDecoder : Decode.Decoder Actor
actorDecoder =
    decode Actor
        |> required "address" Decode.string
        |> required "reason"  Decode.string

actorsDecoder : Decode.Decoder (List Actor)
actorsDecoder =
    Decode.list actorDecoder

dashboardDecoder : Decode.Decoder Dashboard
dashboardDecoder =
    decode Dashboard
        |> required "blacklist" actorsDecoder
        |> required "whitelist" actorsDecoder
        |> required "marklist"  actorsDecoder
