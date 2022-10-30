module Route.PokedexNumber_ exposing (ActionData, Data, Model, Msg, route)

import DataSource exposing (DataSource)
import DataSource.Http
import ErrorPage exposing (ErrorPage)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (src)
import Json.Decode as Decode
import Pages.Msg
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import RouteBuilder exposing (StatefulRoute, StatelessRoute, StaticPayload)
import Server.Response as Response exposing (Response)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { pokedexNumber : String }


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRenderWithFallback
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : DataSource (List RouteParams)
pages =
    DataSource.succeed []


data : RouteParams -> DataSource (Response Data ErrorPage)
data { pokedexNumber } =
    let
        asNumber : Int
        asNumber =
            String.toInt pokedexNumber
                |> Maybe.withDefault -1
    in
    if asNumber < 1 then
        Response.errorPage (ErrorPage.InvalidPokedexNumber pokedexNumber)
            |> DataSource.succeed

    else if asNumber > 898 && asNumber < 10001 || asNumber > 10194 then
        Response.errorPage (ErrorPage.MissingPokedexNumber asNumber)
            |> DataSource.succeed

    else
        DataSource.map2 Data
            (DataSource.Http.get "https://elm-pages-pokedex.netlify.app/.netlify/functions/time"
                Decode.string
            )
            (DataSource.Http.get ("https://pokeapi.co/api/v2/pokemon/" ++ pokedexNumber)
                (Decode.map2 Pokemon
                    (Decode.field "forms" (Decode.index 0 (Decode.field "name" Decode.string)))
                    (Decode.field "types" (Decode.list (Decode.field "type" (Decode.field "name" Decode.string))))
                )
            )
            |> DataSource.map Response.render


type alias Pokemon =
    { name : String
    , abilities : List String
    }


head :
    StaticPayload Data ActionData RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages Pokedex"
        , image =
            { url = static.routeParams |> pokemonImage |> Pages.Url.external
            , alt = static.data.pokemon.name
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title =
            "Pokedex #"
                ++ static.routeParams.pokedexNumber
                ++ " "
                ++ static.data.pokemon.name
        }
        |> Seo.website


type alias Data =
    { time : String
    , pokemon : Pokemon
    }


type alias ActionData =
    {}


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data ActionData RouteParams
    -> View (Pages.Msg.Msg Msg)
view maybeUrl sharedModel static =
    { title = static.data.pokemon.name
    , body =
        [ h1
            []
            [ text static.data.pokemon.name
            ]
        , text (static.data.pokemon.abilities |> String.join ", ")
        , img
            [ static.routeParams |> pokemonImage |> src
            ]
            []
        , p []
            [ text static.data.time
            ]
        ]
    }


pokemonImage : RouteParams -> String
pokemonImage routeParams =
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" ++ routeParams.pokedexNumber ++ ".png"
