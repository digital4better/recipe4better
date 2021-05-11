-- Press a button to send a GET request for random cat GIFs.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/json.html
--

module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http 
import Json.Decode as JsonDecode exposing (Decoder, string, list)



-- MAIN


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL

type alias EcoGestes = List String
type Model
  = Failure
  | Loading
  | Success EcoGestes


init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getEcoGestes)



-- UPDATE


type Msg
  = FetchEcoGestes
  | GotEcoGestes (Result Http.Error EcoGestes)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    FetchEcoGestes ->
      (Loading, getEcoGestes)

    GotEcoGestes result ->
      case result of
        Ok ecoGestes ->
          (Success ecoGestes, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text "Random Cats" ]
    , viewGif model
    ]


viewGif : Model -> Html Msg
viewGif model =
  case model of
    Failure ->
      div []
        [ text "I could not load a random cat for some reason. "
        , button [ onClick FetchEcoGestes ] [ text "Try Again!" ]
        ]

    Loading ->
      text "Loading..."

    Success ecoGestes ->
      div []
        [ button [ onClick FetchEcoGestes, style "display" "block" ] [ text "More Please!" ]      
          , renderEcoGeste ecoGestes
        ] 
renderList : List String -> Html msg
renderList lst =
    ul []
        (List.map (\l -> li [] [ text l ]) lst)
        
renderEcoGeste : EcoGestes -> Html msg
renderEcoGeste ecogestes =
  ul []
    (List.map (\l -> li [] [ text l ]) ecogestes)
    


-- HTTP

getEcoGestes : Cmd Msg
getEcoGestes =
  Http.get
    { url = "/src/data/list.json"
    , expect = Http.expectJson GotEcoGestes gifDecoder
    }


gifDecoder : Decoder EcoGestes
gifDecoder =
  JsonDecode.list JsonDecode.string