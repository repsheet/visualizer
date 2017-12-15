module View exposing (..)

import Html exposing (Html, div, h4, h3, h1, a, text, span, i, tr, th, thead, table, td, tbody, hr)
import Html.Attributes exposing (id, class, href)
import RemoteData exposing (WebData)

import Models exposing (Model, Dashboard, Actor)
import Msgs exposing (Msg)

maybeRender : WebData Dashboard -> Html Msg
maybeRender response =
    case response of
        RemoteData.NotAsked ->
            text ""
        RemoteData.Loading ->
            text "Loading..."
        RemoteData.Success dashboard ->
            div [ class "row" ]
                [ statusBlock "primary"   "Blacklisted" (toString (List.length dashboard.blacklist))
                , statusBlock "secondary" "Marked"      (toString (List.length dashboard.marklist))
                , statusBlock "tertiary"  "Whitelisted" (toString (List.length dashboard.whitelist)) ]
        RemoteData.Failure error ->
            Debug.log (toString error)
            text "ERROR"

statusBlockSection : WebData Dashboard -> Html Msg
statusBlockSection dashboard =
    maybeRender dashboard

statusBlock : String -> String -> String -> Html Msg
statusBlock color section count =
    div [ class "col-md-4 col-sm-6" ]
        [ a [ href "#", class ("dashboard-stat " ++ color) ]
          [ div [ class "details" ]
            [ span [ class "content" ] [ text (section ++ " Actors") ]
            ,   span [ class "value" ] [ text count ] ]
          , i [ class "fa fa-play-circle more" ] []
          ]
        ]

maybeRenderList : WebData Dashboard -> Html Msg
maybeRenderList response =
    case response of
        RemoteData.NotAsked ->
            text ""
        RemoteData.Loading ->
            text "Loading..."
        RemoteData.Success dashboard ->
            div [ class "row" ]
                [ listBlock "Blacklisted" "primary"   dashboard.blacklist
                , listBlock "Marked"      "secondary" dashboard.marklist
                , listBlock "Whitelisted" "tertiary"  dashboard.whitelist ]
        RemoteData.Failure error ->
            Debug.log (toString error)
            text "ERROR"

actorRow : Actor -> Html Msg
actorRow actor =
    tr []
        [ td [] [ text actor.address ]
        , td [] [ text actor.reason ]
        , td [] [ a [ href "#", class "btn-xs btn-tertiary"] [ text "View  ", i [ class "fa fa-chevron-right" ] []] ]
        ]

listBlock : String -> String -> List Actor -> Html Msg
listBlock heading color actors =
    div [ class "col-md-4" ]
        [ div [ class "portlet" ]
              [ div [ class "portlet-header" ]
                    [ h3 [] [ text (heading ++ " Actors") ] ]
              , div [ class "portlet-content" ]
                    [ div [ class "table-responsive" ]
                          [table [ class "table" ]
                               [ thead []
                                     [ tr []
                                       [ th [] [ text "IP Address"]
                                       , th [] [ text "Reason"]
                                       , th [] []
                                       ]
                                     ]
                               , tbody [] (List.map actorRow actors)
                               ]
                          ]
                    , hr [] []
                    , a [ href "#", class ("btn btn-sm btn-" ++ color) ] [ text ("View All " ++ heading ++  " Actors") ]
                    ]
              ]
        ]

listBlockSection : WebData Dashboard -> Html Msg
listBlockSection dashboard =
    maybeRenderList dashboard

view : Model -> Html Msg
view model =
    div []
        [ div [ id "content-header" ]
            [ h1 [] [ text "Dashboard" ] ]
        , div [ id "content-container" ]
            [ div [] [ h4 [] [ text "Summary" ] ]
            , statusBlockSection model.dashboard
            , listBlockSection model.dashboard
            ]
        ]
