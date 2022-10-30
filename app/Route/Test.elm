module Route.Test exposing (ActionData, Data, Model, Msg, route)

import DataSource exposing (DataSource)
import DataSource.Http
import ErrorPage exposing (ErrorPage)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Json.Decode as Decode
import Pages.Msg
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import RouteBuilder exposing (StatelessRoute, StaticPayload)
import Server.Request as Request
import Server.Response as Response exposing (Response)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


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


type alias Data =
    String


data : RouteParams -> DataSource (Response Data ErrorPage)
data _ =
    DataSource.Http.get "http://worldtimeapi.org/api/timezone/America/Los_Angeles"
        (Decode.field "utc_datetime" Decode.string)
        |> DataSource.map Response.render


head :
    StaticPayload Data ActionData RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


type alias ActionData =
    {}


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data ActionData RouteParams
    -> View (Pages.Msg.Msg Msg)
view maybeUrl sharedModel static =
    { title = "ISR"
    , body =
        [ text static.data
        ]
    }
