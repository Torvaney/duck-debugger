module Eliza exposing (..)

import Dict exposing (Dict)
import Regex exposing (Regex, regex)

import String.Interpolate


-- Data


-- A 1st person -> 3rd person lookup
reflections : Dict String String
reflections =
    Dict.fromList
    [ ( "i", "you")
    , ( "am", "are")
    ]


-- Response table
type alias Response
    = ( Regex, List String )


responses : List Response
responses =
    [ ( regex "I need (.*)", [ "Why do you need {0}?" ] )
    , ( regex "(.*)", [ "Please tell me more." ] )
    ]


-- Methods


-- Translate from 1st person to 3rd person
reflectWord : String -> String
reflectWord p1 =
    case Dict.get p1 reflections of
        Just p3 ->
            p3

        Nothing ->
            p1


reflect : String -> String
reflect s =
    String.split " " s |>
    List.map reflectWord |>
    String.join " "


pickOne : List String -> String
pickOne ls =
    case List.head ls of
        Just s ->
            s

        Nothing ->
            "whoops - Nothing"


matchResponse : String -> Response -> Maybe String
matchResponse s (rgx, rsps) =
    Regex.find Regex.All rgx s |>
    List.map .submatches |>
    List.map (List.map (Maybe.withDefault "...")) |>
    List.map (String.Interpolate.interpolate (pickOne rsps)) |>
    List.head


isSomething : Maybe a -> Bool
isSomething m =
    case m of
        Just x ->
            True

        Nothing ->
            False


pickResponse : String -> String
pickResponse s =
    List.map (matchResponse s) responses |>
    List.filter isSomething |>
    List.map (Maybe.withDefault "TODO") |>
    pickOne


respond : String -> String
respond s =
    s |>
    pickResponse |>
    reflect
