module Pages.ElvantoImport exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (ElvantoGroup)
import DjangoSend exposing (CSRFToken, post)
import FilteringTable as FT
import Helpers exposing (formatDate, handleNotSaved)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Notification
import RemoteList as RL
import Urls


type alias Model =
    { tableModel : FT.Model
    }


initialModel : Model
initialModel =
    { tableModel = FT.initialModel }



-- Update


type Msg
    = PullGroups
    | FetchGroups
    | ReceiveButtonResp (Result Http.Error Bool)
    | TableMsg FT.Msg


type alias UpdateProps msg =
    { topLevelMsg : Msg -> msg
    , csrftoken : CSRFToken
    }


update : UpdateProps msg -> Msg -> Model -> ( Model, Notification.Notifications, List (Cmd msg) )
update props msg model =
    case msg of
        PullGroups ->
            ( model
            , Notification.addInfo [] "Groups are being imported, it may take a couple of minutes"
            , [ buttonReq props Urls.api_act_pull_elvanto_groups ]
            )

        FetchGroups ->
            ( model
            , Notification.addSuccess [] "Groups are being fetched, it may take a couple of minutes"
            , [ buttonReq props Urls.api_act_fetch_elvanto_groups ]
            )

        ReceiveButtonResp (Ok _) ->
            ( model, [], [] )

        ReceiveButtonResp (Err _) ->
            ( model, Notification.addNotSaved [], [] )

        TableMsg tableMsg ->
            ( { model | tableModel = FT.update tableMsg model.tableModel }
            , []
            , []
            )


buttonReq : UpdateProps msg -> String -> Cmd msg
buttonReq props url =
    post props.csrftoken url [] (Decode.succeed True)
        |> Http.send (props.topLevelMsg << ReceiveButtonResp)



-- View


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , topMsg : Msg -> msg
    , toggleElvantoGroupSync : ElvantoGroup -> msg
    , groups : RL.RemoteList ElvantoGroup
    }


view : Props msg -> Model -> Html msg
view props { tableModel } =
    Html.div []
        [ Html.div [ Css.w_full, Css.flex ] [ fetchButton props, pullButton props ]
        , Html.br [] []
        , FT.table { top = props.tableMsg } [] tableHead tableModel (groupRow props) props.groups
        ]


tableHead : FT.Head
tableHead =
    FT.Head
        [ ""
        , "Last Synced"
        , "Sync?"
        ]


fetchButton : Props msg -> Html msg
fetchButton props =
    Html.button
        [ onClick (props.topMsg FetchGroups)
        , A.id "fetch_button"
        , Css.btn
        , Css.btn_green
        , Css.flex_1
        ]
        [ Html.text "Fetch Groups" ]


pullButton : Props msg -> Html msg
pullButton props =
    Html.button
        [ onClick (props.topMsg PullGroups)
        , A.id "pull_button"
        , Css.btn
        , Css.btn_blue
        , Css.flex_1
        ]
        [ Html.text "Pull Groups" ]


groupRow : Props msg -> ElvantoGroup -> FT.Row msg
groupRow props group =
    FT.Row
        []
        [ FT.Cell [] [ Html.text group.name ]
        , FT.Cell [] [ Html.text (formatDate group.last_synced) ]
        , FT.Cell [] [ toggleSyncButton props group ]
        ]
        (toString group.pk)


toggleSyncButton : Props msg -> ElvantoGroup -> Html msg
toggleSyncButton props group =
    case group.sync of
        True ->
            syncingButton props group

        False ->
            notSyncingButton props group


syncingButton : Props msg -> ElvantoGroup -> Html msg
syncingButton props group =
    button_ props [ Css.btn, Css.btn_green ] "Syncing" group


notSyncingButton : Props msg -> ElvantoGroup -> Html msg
notSyncingButton props group =
    button_ props [ Css.btn, Css.btn_grey ] "Disabled" group


button_ : Props msg -> List (Html.Attribute msg) -> String -> ElvantoGroup -> Html msg
button_ props styling label group =
    Html.button
        ([ A.id "elvantoGroupButton"
         , onClick (props.toggleElvantoGroupSync group)
         ]
            ++ styling
        )
        [ Html.text label ]
