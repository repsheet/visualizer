module Msgs exposing (..)

import RemoteData exposing (WebData)

import Models exposing (Dashboard)

type Msg
    = OnFetchDashboard (WebData Dashboard)
