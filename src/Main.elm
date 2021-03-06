module Main exposing (..)

import Color exposing (..)
import Html exposing (Html, program)
import Json.Decode as Json
import String.Extra
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (onClick)
import Element.Input as Input
import Style
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
import Markdown
import Eliza


-- Style


type MyStyles
    = Default
    | Title
    | Summary
    | InputBoxEmpty
    | Button
    | UserMessage
    | ElizaMessage


baseStyle : List (Style.Property class variation)
baseStyle =
    [ Font.size 20
    , Font.typeface
        [ Font.font "Helvetica"
        ]
    ]


stylesheet : Style.StyleSheet MyStyles variation
stylesheet =
    Style.styleSheet
        [ Style.style Default
            ([ Color.text black ] ++ baseStyle)
        , Style.style Title
            [ Color.text black
            , Font.size 30
            , Font.typeface
                [ Font.font "Helvetica"
                ]
            ]
        , Style.style Summary
            [ Color.text black
            , Font.size 18
            , Font.typeface
                [ Font.font "Helvetica"
                ]
            ]
        , Style.style InputBoxEmpty
            ([ Color.text darkGray ] ++ baseStyle)
        , Style.style Button
            ([ Color.text black
             , Border.all 0.1
             , Border.rounded 8
             , Color.background white
             , Shadow.simple
             , Font.size 20
             ]
                ++ baseStyle
            )
        , Style.style UserMessage
            ([ Color.text white
             , Border.all 0.1
             , Border.rounded 8
             , Color.background blue
             , Color.border darkBlue
             , Shadow.simple
             ]
                ++ baseStyle
            )
        , Style.style ElizaMessage
            ([ Color.text black
             , Border.all 0.1
             , Border.rounded 8
             , Color.background lightGray
             , Color.border gray
             , Shadow.simple
             ]
                ++ baseStyle
            )
        ]



-- MODEL


type alias Exchange =
    { eliza : String
    , user : String
    }


type alias Model =
    { history : List Exchange
    , typing : String
    , asking : Maybe String
    , textKey : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { history = []
      , typing = ""
      , asking = Nothing
      , textKey = 0
      }
    , Cmd.none
    )



-- MESSAGES


type Msg
    = Ask
    | Respond String
    | Typing String



-- Placeholder for now
-- VIEW


formatResponse : String -> String
formatResponse s =
    s
        |> String.Extra.softWrap 20


wrapperEl : Element MyStyles variation msg -> Element MyStyles variation msg
wrapperEl e =
    el Default [] e


viewExchange : Exchange -> Element MyStyles variation msg
viewExchange e =
    column Default
        [ width (percent 100) ]
        [ el Default [ padding 5 ] empty
        , wrapperEl <| el UserMessage [ alignRight, padding 2 ] <| text <| formatResponse e.user
        , wrapperEl <| el ElizaMessage [ alignLeft, padding 2 ] <| text <| formatResponse e.eliza
        , el Default [ padding 5 ] empty
        ]


txt : Model -> Input.Text style variation Msg
txt model =
    { onChange = Typing
    , value =
        if isBlank model.typing then
            "Enter text here"
        else
            model.typing
    , label = Input.hiddenLabel "text input"
    , options =
        [ Input.allowSpellcheck
        , Input.focusOnLoad
        , Input.textKey (toString model.textKey)
        ]
    }


inputStyle : Model -> MyStyles
inputStyle model =
    if isBlank model.typing then
        InputBoxEmpty
    else
        Default


onEnter : msg -> Element.Attribute variation msg
onEnter message =
    Element.Events.on "keyup" <|
        Json.andThen
            (\keyCode ->
                if keyCode == 13 then
                    Json.succeed message
                else
                    Json.fail (toString keyCode)
            )
            Element.Events.keyCode


viewChat : Model -> Element MyStyles variation Msg
viewChat model =
    column Default
        [ width (percent 33), height (percent 80) ]
        [ column Default
            [ scrollbars, height (percent 80), alignBottom ]
            (List.map viewExchange <| List.reverse model.history)
        , row Default
            []
            [ el Default
                [ width (percent 80), alignLeft ]
              <|
                Input.text (inputStyle model) [ onEnter Ask ] (txt model)
            , button Button
                [ onClick Ask, alignRight, width (percent 20) ]
                (text "Ask")
            ]
        ]


summary : String
summary =
    """
[Duck debugging](https://en.wikipedia.org/wiki/Rubber_duck_debugging) is a method
of solving problems by talking them through. The listener could be a colleague,
a friend or even... a rubber duck? A computer program?

Try it out! Talk through your problem with the \x1F986.

The Duck Debugger is based on the seminal computer program
[ELIZA](https://en.wikipedia.org/wiki/ELIZA), with minor details altered to
suit duck debugging.

[Source code](https://github.com/Torvaney/duck-debugger)
"""


view : Model -> Html Msg
view model =
    viewport stylesheet <|
        (row Default
            [ width (percent 100), height (percent 100) ]
            [ column Default
                [ center, width fill, height fill ]
                [ el Default [ height (percent 2) ] empty
                , el Title [ height (percent 10) ] (text "\x1F986 The Duck Debugger \x1F986")
                , (viewChat model)
                , column Summary [ height (percent 10), width (percent 60) ]
                    [ html <| Markdown.toHtml [] summary
                    , el Default [ height (percent 50) ] empty
                    ]
                ]
            ]
        )



-- UPDATE


isBlank : String -> Bool
isBlank s =
    String.isEmpty <| String.Extra.replace " " "" s


updateHistory : Model -> Maybe String -> String -> List Exchange
updateHistory model question response =
    case question of
        Just q ->
            if isBlank q then
                model.history
            else
                { user = q, eliza = response } :: model.history

        Nothing ->
            model.history


sendResponse : String -> Msg
sendResponse s =
    Respond s


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ask ->
            ( { model
                | typing = ""
                , asking = Just model.typing
                , textKey = model.textKey + 1
              }
            , Eliza.respond sendResponse model.typing
            )

        Respond s ->
            ( { model
                | typing = ""
                , asking = Nothing
                , history = updateHistory model model.asking s
              }
            , Cmd.none
            )

        Typing s ->
            ( { model | typing = s }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
