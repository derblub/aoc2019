
-- https://adventofcode.com/2019/day/10

--   elm make Main.elm

module Main exposing (Input1, Input2, Output1, Output2, compute1, compute2, input_, main, parse1, parse2)

import Functions
import Arithmetic
import Dict exposing (Dict)
import Dict.Extra
import List.Extra
import RollingList exposing (RollingList)


type alias Coord = ( Int, Int )
type alias Input1 = List Coord
type alias Input2 = List Coord
type alias Output1 = Int
type alias Output2 = Int


parse1 : String -> Input1
parse1 string =
    string
        |> String.lines
        |> List.indexedMap
            (\y line ->
                line
                    |> String.toList
                    |> List.indexedMap
                        (\x char ->
                            if char == '#' then Just ( x, y )
                            else Nothing
                        )
                    |> List.filterMap identity
            )
        |> List.concat


parse2 : String -> Input2
parse2 string = parse1 string


compute1 : Input1 -> Output1
compute1 asteroids =
    asteroids
        |> List.map (visibleAsteroids asteroids)
        |> List.sortBy (\( howMany, _, _ ) -> howMany)
        |> List.reverse
        |> List.head
        |> Functions.unsafeMaybe "compute1"
        |> (\( howMany, _, _ ) -> howMany)


visibleAsteroids :
    List Coord
    -> Coord
    -> ( Int, List ( Slope, List { otherAsteroid : Coord, slope : Slope, distance : Float } ), Coord )
visibleAsteroids asteroids (( x1, y1 ) as asteroid) =
    let
        slopesAndDistances : List { otherAsteroid : Coord, slope : Slope, distance : Float }
        slopesAndDistances =
            asteroids
                |> List.filterMap
                    (\(( x2, y2 ) as otherAsteroid) ->
                        if asteroid == otherAsteroid then Nothing
                        else
                            Just <|
                                let
                                    x_ = x2 - x1
                                    y_ = y2 - y1
                                    gcd = Arithmetic.gcd x_ y_
                                    slope = ( x_ // gcd, y_ // gcd )
                                    distance = sqrt (toFloat (x_ ^ 2 + y_ ^ 2))
                                in
                                    { slope = slope
                                    , otherAsteroid = otherAsteroid
                                    , distance = distance
                                    }
                    )

        grouped : List ( Slope, List { otherAsteroid : Coord, slope : Slope, distance : Float } )
        grouped = slopesAndDistances
                    |> Dict.Extra.groupBy .slope
                    |> Dict.toList

        howMany = List.length grouped
    in
        ( howMany, grouped, asteroid )


isVisible : Coord -> Coord -> Bool
isVisible ( x1, y1 ) ( x2, y2 ) =
    Arithmetic.gcd (x2 - x1) (y2 - y1) == 1


compute2 : Input2 -> Output2
compute2 asteroids =
    let
        ( _, data, station ) = asteroids
                |> List.map (visibleAsteroids asteroids)
                |> List.sortBy (\( howMany, _, _ ) -> howMany)
                |> List.reverse
                |> List.head
                |> Functions.unsafeMaybe "compute2 getting data"

        dataZipper : AsteroidZipper
        dataZipper = data
                |> List.sortBy (Tuple.first >> angle)
                |> List.map (Tuple.mapSecond (List.sortBy .distance))
                |> RollingList.fromList
                |> rollUntilSlope ( 0, -1 )
    in
    go 200 dataZipper station
        |> coordToNumber


rollUntilSlope : Slope -> AsteroidZipper -> AsteroidZipper
rollUntilSlope slope zipper =
    if Maybe.map Tuple.first (RollingList.current zipper) == Just slope then
        zipper
    else
        rollUntilSlope slope (RollingList.roll zipper)


coordToNumber : Coord -> Int
coordToNumber ( x, y ) = x * 100 + y


angle : Slope -> Float
angle ( x, y ) = atan2 (toFloat y) (toFloat x)


go : Int -> AsteroidZipper -> Coord -> Coord
go toDestroy zipper station =
    let
        ( destroyedAsteroid, newZipper ) =
            destroyOneAsteroid zipper
    in
    if toDestroy == 1 then
        destroyedAsteroid

    else
        go (toDestroy - 1) newZipper station


destroyOneAsteroid : AsteroidZipper -> ( Coord, AsteroidZipper )
destroyOneAsteroid rollingList =
    let
        ( slope, asteroids ) =
            RollingList.current rollingList
                |> Functions.unsafeMaybe "current destroyOneAsteroid"

        ( currentAsteroid, newAsteroids ) =
            List.Extra.uncons asteroids
                |> Functions.unsafeMaybe "uncons destroyOneAsteroid"
    in
    if List.isEmpty newAsteroids then
        -- remove the whole zipper entry
        ( currentAsteroid.otherAsteroid
        , dropOne rollingList
        )

    else
        -- remove one from list
        ( currentAsteroid.otherAsteroid
        , rollingList
            |> setCurrent ( slope, newAsteroids )
            |> RollingList.roll
        )


setCurrent : a -> RollingList a -> RollingList a
setCurrent x rollingList = { rollingList | next = x :: List.drop 1 rollingList.next }


dropOne : RollingList a -> RollingList a
dropOne rollingList = { rollingList | next = List.drop 1 rollingList.next }


type alias Slope = ( Int, Int )


type alias AsteroidZipper =
    RollingList ( Slope, List { otherAsteroid : Coord, slope : Slope, distance : Float } )



input_ : String
input_ =
    """
.###.#...#.#.##.#.####..
.#....#####...#.######..
#.#.###.###.#.....#.####
##.###..##..####.#.####.
###########.#######.##.#
##########.#########.##.
.#.##.########.##...###.
###.#.##.#####.#.###.###
##.#####.##..###.#.##.#.
.#.#.#####.####.#..#####
.###.#####.#..#..##.#.##
########.##.#...########
.####..##..#.###.###.#.#
....######.##.#.######.#
###.####.######.#....###
############.#.#.##.####
##...##..####.####.#..##
.###.#########.###..#.##
#.##.#.#...##...#####..#
##.#..###############.##
##.###.#####.##.######..
##.#####.#.#.##..#######
...#######.######...####
#....#.#.#.####.#.#.#.##
"""

        |> Functions.removeNewlinesAtEnds


main : Program () ( Output1, Output2 ) Never
main =
    Functions.program
        { input = input_
        , parse1 = parse1
        , parse2 = parse2
        , compute1 = compute1
        , compute2 = compute2
        }
