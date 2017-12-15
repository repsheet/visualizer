module Msgs exposing (..)

import RemoteData exposing (WebData)
import Navigation exposing (Location)

import Models exposing (Dashboard)

type Msg
    = OnFetchDashboard (WebData Dashboard)
    | OnLocationChange Location
