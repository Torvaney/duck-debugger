module Eliza exposing (respond)

import Dict exposing (Dict)
import Random
import Random.Extra
import Regex exposing (Regex, regex)
import String.Interpolate
import Eliza.Data


-- Data
-- c.f. https://github.com/jezhiggins/eliza.py/blob/master/eliza.py


type alias Reflection =
    Dict String String


type alias Response =
    ( Regex, List String )



-- Methods


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


pickOne : (String -> msg) -> List String -> Cmd msg
pickOne f ls =
    Random.Extra.sample ls
        |> Random.map (Maybe.withDefault "I don't know what to say...")
        |> Random.generate f


matchPattern : Regex.Regex -> String -> Maybe Regex.Match
matchPattern pattern s =
    Regex.find (Regex.AtMost 1) pattern s
        |> List.head


extractSubmatches : Regex.Match -> List String
extractSubmatches match =
    match.submatches
        |> List.map (Maybe.withDefault "")


interpolateResponses : List String -> List String -> List String
interpolateResponses candidates fill =
    let
        reflectedFill =
            List.map reflect fill

        interpolateCandidates =
            \c -> String.Interpolate.interpolate c reflectedFill
    in
        List.map interpolateCandidates candidates


matchResponse : String -> Response -> Maybe (List String)
matchResponse s ( pattern, candidates ) =
    String.toLower s
        |> matchPattern pattern
        |> Maybe.map extractSubmatches
        |> Maybe.map (interpolateResponses candidates)


pickResponse : (String -> msg) -> String -> Cmd msg
pickResponse f s =
    List.map (matchResponse s) Eliza.Data.responses
        |> List.filterMap identity
        |> List.head
        |> Maybe.withDefault []
        |> pickOne f


respond : (String -> msg) -> String -> Cmd msg
respond f s =
    pickResponse f s
