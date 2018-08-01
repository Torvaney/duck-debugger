module Main exposing (..)

import Color exposing (..)
import Html exposing(Html, program)
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

import Eliza


-- Style

type MyStyles
    = Default
    | InputBoxEmpty
    | Button
    | UserMessage
    | ElizaMessage


stylesheet : Style.StyleSheet MyStyles variation
stylesheet =
    Style.styleSheet
        [ Style.style Default
            [ Color.text black
            , Color.background white
            , Font.size 20
            , Font.typeface
                [ Font.font "Helvetica"
                ]
            ]
        , Style.style InputBoxEmpty
            [ Color.text darkGray
            , Color.background white
            , Font.size 20
            , Font.typeface
                [ Font.font "Helvetica"
                ]
            ]
        , Style.style Button
            [ Color.text black
            , Border.all 0.1
            , Border.rounded 8
            , Color.background white
            , Shadow.simple
            , Font.size 20
            , Font.typeface
                [ Font.font "Helvetica"
                ]
            ]
        , Style.style UserMessage
            [ Color.text white
            , Border.all 0.1
            , Border.rounded 8
            , Color.background blue
            , Shadow.simple
            , Font.size 20
            , Font.typeface
                [ Font.font "Helvetica"
                ]
            ]
        , Style.style ElizaMessage
            [ Color.text black
            , Border.all 0.1
            , Border.rounded 8
            , Color.background white
            , Color.border darkGray
            , Shadow.simple
            , Font.size 20
            , Font.typeface
                [ Font.font "Helvetica"
                ]
            ]
        ]


-- MODEL


type alias Exchange =
    { eliza : String
    , user  : String
    }

type alias Model =
    { history : List Exchange
    , typing  : String
    , textKey : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { history = [ ]
      , typing  = ""
      , textKey = 0
      }
    , Cmd.none
    )


-- MESSAGES


type Msg
    = Ask
    | Typing String  -- Placeholder for now


-- VIEW


wrapperEl : Element MyStyles variation msg -> Element MyStyles variation msg
wrapperEl e =
    el Default [] e


viewExchange : Exchange -> Element MyStyles variation msg
viewExchange e =
    column Default [ width (percent 100) ]
        [ el Default [ padding 5 ] empty
        , wrapperEl <| el UserMessage [ alignRight, padding 2 ] (text e.user)
        , wrapperEl <| el ElizaMessage [ alignLeft, padding 2 ] (text e.eliza)
        , el Default [ padding 5 ] empty
        ]


txt : Model -> Input.Text style variation Msg
txt model =
    { onChange = Typing
    , value    = if isBlank model.typing then "Enter text here" else model.typing
    , label    = Input.hiddenLabel "text input"
    , options  = [ Input.allowSpellcheck
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
    column Default [ width (percent 33), height (percent 80) ]
      [ column Default
          [ scrollbars, height (percent 80), alignBottom ]
          ( List.map viewExchange <| List.reverse model.history )
      , row Default
          []
          [ el Default
              [ width (percent 80), alignLeft] <|
                Input.text (inputStyle model) [ onEnter Ask ] (txt model)
          , button Button
              [ onClick Ask, alignRight, width (percent 20) ]
              ( text "Ask" )
          ]
      ]


view : Model -> Html Msg
view model =
    viewport stylesheet <|
      (row Default
        [ width (percent 100), height (percent 100) ]
        [ column Default
          [ center, width fill, height fill ]
          [ el Default [height (percent 10)] (text "The Duck Debugger")
          , ( viewChat model )
          , el Default [height (percent 10)] (text "---")
          ]
        ]
      )


-- UPDATE


respond : String -> Exchange
respond s =
    { eliza = Eliza.respond s
    , user  = s
    }


isBlank : String -> Bool
isBlank s =
    String.isEmpty <| String.Extra.replace " " "" s


updateHistory : Model -> List Exchange
updateHistory model =
    if isBlank model.typing then
        model.history
    else
        (respond model.typing) :: model.history


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ask ->
            ( { model
              | history = updateHistory model
              , typing  = ""
              , textKey = model.textKey + 1
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
