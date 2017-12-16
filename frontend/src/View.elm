module View exposing (..)

import Html exposing (Html, div, h4, h3, h1, a, text, span, i, tr, th, thead, table, td, tbody, hr)
import Html.Attributes exposing (id, class, href)
import RemoteData exposing (WebData)

import Models exposing (Model, Dashboard, Actor)
import Msgs exposing (Msg)

maybeDashboard : WebData Dashboard -> Html Msg
maybeDashboard response =
    case response of
        RemoteData.NotAsked ->
            text ""
        RemoteData.Loading ->
            text "Loading..."
        RemoteData.Success dashboard ->
            div [] 
                [ h4 [] [ text "Summary" ]
                , div [ class "row" ]
                    [ statusBlock "primary"   "Blacklisted" "blacklist" (dashboard.blacklist |> List.length |> toString)
                    , statusBlock "secondary" "Marked"      "marklist"  (dashboard.marklist  |> List.length |> toString)
                    , statusBlock "tertiary"  "Whitelisted" "whitelist" (dashboard.whitelist |> List.length |> toString) ]
                , div [ class "row" ]
                    [ listBlock "Blacklisted" "primary"   dashboard.blacklist
                    , listBlock "Marked"      "secondary" dashboard.marklist
                    , listBlock "Whitelisted" "tertiary"  dashboard.whitelist ]
                ]                
        RemoteData.Failure error ->
            Debug.log (toString error)
            text "ERROR"

statusBlock : String -> String -> String -> String -> Html Msg
statusBlock color section url count =
    div [ class "col-md-4 col-sm-6" ]
        [ a [ href ("#" ++ url), class ("dashboard-stat " ++ color) ]
          [ div [ class "details" ]
            [ span [ class "content" ] [ text (section ++ " Actors") ]
            ,   span [ class "value" ] [ text count ] ]
          , i [ class "fa fa-play-circle more" ] []
          ]
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

maybeReport : String -> WebData Dashboard -> Html Msg
maybeReport section response =
    case response of
        RemoteData.NotAsked ->
            text ""
        RemoteData.Loading ->
            text "Loading..."
        RemoteData.Success dashboard ->
            case section of
                "Blacklisted" ->
                    listPaginated section dashboard.blacklist
                "Whitelisted" ->
                    listPaginated section dashboard.whitelist
                "Marked" ->
                    listPaginated section dashboard.marklist
                _ ->
                    listPaginated "Blacklisted" dashboard.blacklist
        RemoteData.Failure error ->
            Debug.log (toString error)
            text "ERROR"

listPaginated : String -> List Actor -> Html Msg
listPaginated section actors =
    div [ class "row" ]
        [ div [ class "col-md-12" ]
              [ div [ class "portlet" ]
                    [ div [ class "portlet-header" ]
                          [ h3 [] [ text ("All " ++ section ++ " Actors") ] ]
                    , div [ class "portlet-content" ]
                          [ div [ class "table-responsive" ]
                                [ table [ class "table" ]
                                      [ thead []
                                            [ tr []
                                              [ th [] [ text "IP Address" ]
                                              , th [] [ text "Reason" ]
                                              ]
                                            ]
                                      , tbody [] (List.map actorRow actors)
                                      ]
                                ]
                          ]
                    ]
              ]
        ]

actorRow : Actor -> Html Msg
actorRow actor =
    tr []
        [ td [] [ text actor.address ]
        , td [] [ text actor.reason ]
        , td [] [ a [ href ("#/actors/" ++ actor.address), class "btn-xs btn-tertiary"] [ text "View  ", i [ class "fa fa-chevron-right" ] []] ]
        ]

dashboard : WebData Dashboard -> Html Msg
dashboard response =
    div []
        [ div [ id "content-header" ]
            [ h1 [] [ text "Dashboard" ] ]
        , div [ id "content-container" ]
            [ maybeDashboard response ]        
        ]

report : String -> WebData Dashboard -> Html Msg
report section response =
    div []
        [ div [ id "content-header" ]
            [ h1 [] [ text (section ++ " Actors") ] ]
        , div [ id "content-container" ]
            [ maybeReport section response ]
        ]

view : Model -> Html Msg
view model =
    case model.route of
        Models.DashboardRoute ->
            dashboard model.dashboard
        Models.BlacklistRoute ->
            report "Blacklisted" model.dashboard
        Models.WhitelistRoute ->
            report "Whitelisted" model.dashboard
        Models.MarklistRoute ->
            report "Marked" model.dashboard
        Models.ActorRoute address ->
            div []
                [ h1 [] [ text ("Actor " ++ address) ] ]
        Models.NotFoundRoute ->
            notFoundView

notFoundView : Html Msg
notFoundView =
    div []
        [ text "Not found" ]
