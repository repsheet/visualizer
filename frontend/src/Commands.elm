module Commands exposing (..)

import Http
import RemoteData
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)

import Models exposing (Dashboard)
import Msgs exposing (Msg)

fetchDashboard : Cmd Msg
fetchDashboard =
    Http.get fetchDashboardUrl dashboardDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchDashboard

fetchDashboardUrl : String
fetchDashboardUrl =
    "http://localhost:4000/dashboard"

dashboardDecoder : Decode.Decoder Dashboard
dashboardDecoder =
    decode Dashboard
        |> required "blacklisted" Decode.string
        |> required "whitelisted" Decode.string
        |> required "marked"      Decode.string
