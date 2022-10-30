module Route.Index exposing (ActionData, Data, Model, Msg, route)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (href)
import Pages.Msg
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path
import Route
import RouteBuilder exposing (StatelessRoute, StaticPayload)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { message : String
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : DataSource Data
data =
    DataSource.succeed Data
        |> DataSource.andMap
            (DataSource.succeed "Hello!")


head :
    StaticPayload Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = [ "images", "icon-png.png" ] |> Path.join |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Welcome to elm-pages!"
        , locale = Nothing
        , title = "elm-pages is running"
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data ActionData RouteParams
    -> View (Pages.Msg.Msg Msg)
view maybeUrl sharedModel app =
    { title = "elm-pages is running"
    , body =
        [ Html.h1 [] [ text "elm-pages is up and running!" ]
        , Html.p []
            [ text <| "The message is: " ++ app.data.message
            ]
        , ul []
            [ li []
                [ strong [] [ text "Static" ]
                , ul []
                    [ li []
                        [ Route.Blog__Slug_ { slug = "hello" }
                            |> Route.link [] [ text "/blog/hello" ]
                        ]
                    , li []
                        [ Route.Pokemon
                            |> Route.link [] [ text "/pokemon" ]
                        ]
                    ]
                ]
            , li []
                [ strong [] [ text "Incremental Static Regeneration" ]
                , ul []
                    [ li []
                        [ Route.Test
                            |> Route.link [] [ text "/test" ]
                        ]
                    , li []
                        [ Route.Test__Slug_ { slug = "wassup" }
                            |> Route.link [] [ text "/test/wassup" ]
                        ]
                    , li []
                        [ Route.Test__Slug_ { slug = "another" }
                            |> Route.link [] [ text "/test/another" ]
                        ]
                    , li []
                        [ Route.PokedexNumber_ { pokedexNumber = "1" }
                            |> Route.link [] [ text "/1" ]
                        ]
                    ]
                ]
            , li []
                [ strong [] [ text "Serverless" ]
                , ul []
                    [ li []
                        [ Route.Serverless
                            |> Route.link [] [ text "/serverless" ]
                        ]
                    , li []
                        [ Route.Serverless__Slug_ { slug = "yo" }
                            |> Route.link [] [ text "/serverless/yo" ]
                        ]
                    ]
                ]
            ]
        ]
    }
