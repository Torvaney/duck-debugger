module Eliza exposing (..)

import Dict exposing (Dict)
import Regex exposing (Regex, regex)
import String.Extra
import String.Interpolate
import Eliza.Data


-- Data
-- c.f. https://github.com/jezhiggins/eliza.py/blob/master/eliza.py


type alias Reflection =
    Dict String String


type alias Response =
    ( Regex, List String )



-- Methods
-- Translate from 1st person to 3rd person


reflectWord : String -> String
reflectWord p1 =
    case Dict.get p1 Eliza.Data.reflections of
        Just p3 ->
            p3

        Nothing ->
            p1


reflect : String -> String
reflect s =
    String.split " " s
        |> List.map reflectWord
        |> String.join " "


pickOne : List String -> String
pickOne ls =
    case List.head ls of
        Just s ->
            s

        -- It should never come to this...
        -- See "( (.*), "Please tell me more" ) in Eliza.Data
        Nothing ->
            "I don't know what to say..."


matchResponse : String -> Response -> Maybe String
matchResponse s ( rgx, rsps ) =
    s
        |> String.toLower
        |> Regex.find Regex.All rgx
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault "..."))
        |> List.map (List.map reflect)
        |> List.map (String.Interpolate.interpolate (pickOne rsps))
        |> List.head


isSomething : Maybe a -> Bool
isSomething m =
    case m of
        Just x ->
            True

        Nothing ->
            False


pickResponse : String -> String
pickResponse s =
    List.map (matchResponse s) Eliza.Data.responses
        |> List.filter isSomething
        |> List.map (Maybe.withDefault "TODO")
        |> pickOne


respond : String -> String
respond s =
    s
        |> pickResponse
        |> String.Extra.toSentenceCase
