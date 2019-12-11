module Menu exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http as Http
import Browser.Navigation as Navigation

import Route exposing (..)

import OAuth
import RemoteData exposing (RemoteData, WebData, succeed)

import MyError exposing (buildErrorMessage)

import Bootstrap.Table as Table
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Text as Text
import Bootstrap.Card.Block as Block
import Bootstrap.Navbar as Navbar

import SearchBook as SearchBook
import Page exposing (..)
import Session exposing (..)


initialState : Maybe OAuth.Token -> (Navbar.State, Cmd Msg)
initialState maybeToken =
    Navbar.initialState NavbarMsg


type alias MenuAction =
    { title : String
    , description : String
    , imageLink : String
    , page : Page
    -- , isAcive : Bool
    }


type Msg
    = NavbarMsg Navbar.State
    | ChangedPage Page


menuActionsNoAccessToken : List MenuAction
menuActionsNoAccessToken =
    [
        {
            title = "Login"
            , description = "You must log in to use the library"
            , imageLink = ""
            , page = LoginPage
        }
    ]


menuActionsWithAccessToken : List MenuAction
menuActionsWithAccessToken =
    [
        {
            title = "Book selector"
            , description = "Add (new) books to the library"
            , imageLink = ""
            , page = BookSelectorPage
        }
    ]

--
-- VIEW
--

view : Session -> Html Msg
view session =
        Navbar.config NavbarMsg
            |> Navbar.withAnimation
            |> Navbar.collapseMedium
            |> Navbar.brand [] [ img [ src "src/resources/lunatech_logo.png", class "d-inline-block align-top", style  "width" "200px"  ] [ text "Lunatech" ] ]
            |> Navbar.items
                ( case session.token of
                    Nothing ->
                        List.map (viewActionCard session) menuActionsNoAccessToken

                    Just token ->
                        List.map (viewActionCard session) menuActionsWithAccessToken
                )
        |> Navbar.view session.navbarState

viewActionCard : Session -> MenuAction -> Navbar.Item Msg
viewActionCard session menuAction =
    let
        menuActionIsActive = session.page == menuAction.page 
    in
        case menuActionIsActive of
            True ->
                Navbar.itemLinkActive [ onClick (ChangedPage menuAction.page)  ] [ text menuAction.title ]
            False ->
                Navbar.itemLink [ onClick (ChangedPage menuAction.page)  ] [ text menuAction.title ]


update : Msg -> Session -> ( Session, Cmd Msg )
update msg session =
    case msg of
        NavbarMsg state ->
            ( { session | navbarState = state }, Cmd.none )

        -- ChangedPage page ->
        --    ( model, Cmd.none )
        ChangedPage page ->
            ( changedPageSession page session, Cmd.none )


subscriptions : Session -> Sub Msg
subscriptions session =
    Navbar.subscriptions session.navbarState NavbarMsg