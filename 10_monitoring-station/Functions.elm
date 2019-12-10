module Functions exposing
    ( program
    , removeNewlinesAtEnds
    , unsafeMaybe
    )


program :
    { input : String
    , parse1 : String -> input1
    , parse2 : String -> input2
    , compute1 : input1 -> output1
    , compute2 : input2 -> output2
    }
    -> Program () ( output1, output2 ) Never
program { input, parse1, parse2, compute1, compute2 } =
    Platform.worker
        { init =
            \_ ->
                ( ( input
                        |> parse1
                        |> compute1
                        |> Debug.log "Output 1"
                  , input
                        |> parse2
                        |> compute2
                        |> Debug.log "Output 2"
                  )
                , Cmd.none
                )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }



unsafeMaybe : String -> Maybe a -> a
unsafeMaybe location maybe =
    case maybe of
        Just x ->
            x

        Nothing ->
            Debug.todo location


removeNewlinesAtEnds : String -> String
removeNewlinesAtEnds string =
    if String.startsWith "\n" string then
        removeNewlinesAtEnds (String.dropLeft 1 string)

    else if String.endsWith "\n" string then
        removeNewlinesAtEnds (String.dropRight 1 string)

    else
        string
