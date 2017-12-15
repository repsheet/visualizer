module View exposing (..)

import Html exposing (Html, div, h4, h1, a, text, span, i)
import Html.Attributes exposing (id, class, href)
import RemoteData exposing (WebData)

import Models exposing (Model, Dashboard)
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

view : Model -> Html Msg
view model =
    div []
        [ div [ id "content-header" ]
            [ h1 [] [ text "Dashboard" ] ]
        , div [ id "content-container" ]
            [ div [] [ h4 [] [ text "Summary" ] ]
            , statusBlockSection model.dashboard
            ]
        ]
