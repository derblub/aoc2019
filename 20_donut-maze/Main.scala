// https://adventofcode.com/2019/day/20

//    scalac Main.scala -d classes  && scala -classpath classes Main

import java.awt.Point
import scala.io.Source
import scala.collection.mutable
import scala.collection.mutable.ListBuffer


object Main {


  lazy val input: List[String] = Source.fromFile("input.txt").getLines.toList
  val maze: mutable.HashMap[Point, Char] = readMap()
  val center: Point = get_center(maze)
  val (start, end, portals): (Point, Point, Set[Portal]) = findPortals(maze, center)
  var minFoundSoFar = 20000


  case class Portal(label: String, outerPt: Point, innerPt: Point) {
    def findOtherPoint(point: Point): Point = {
      if (point == outerPt) innerPt else outerPt
    }
  }

  case class PotentialTarget(portal: Portal, pt: Point, stepsAway: Int) {
    override def toString: String = {
      val otherPt = portal.findOtherPoint(pt)

      val outerStr = if (pt == portal.outerPt) "OUTER" else "INNER"
      s"$stepsAway steps to ${portal.label} $outerStr, warp from [${pt.x}, ${pt.y}] to [${otherPt.x}, ${otherPt.y}]"
    }

    def isOuter: Boolean = portal.outerPt == pt
    def adjustDepth(depth: Option[Int]): Option[Int] = depth match {
      case Some(value) => if (portal.label == "ZZ") Some(value) else if (isOuter) Some(value -1) else Some(value + 1)
      case None => None
    }
  }

  def iterateMovesUntilAtEnd(moveTaken: PotentialTarget, stepsTakenToHere: Int, path: List[PotentialTarget], currentLevel: Option[Int]): Int = {
    val position = moveTaken.pt
    if (position == end && onLevelZero(currentLevel)) {
      updateMinSoFar(stepsTakenToHere)
      return stepsTakenToHere
    }

    val lastPortal = moveTaken.portal
    val stepsAfterTakingPortal = stepsTakenToHere + 1
    val positionAfterPortal = lastPortal.findOtherPoint(position)
    if (stepsAfterTakingPortal > minFoundSoFar) {
      return stepsAfterTakingPortal  * 100
    }

    if (currentLevel.isDefined && currentLevel.get > 30) {
      return minFoundSoFar * 100
    }

    val potentialMoves = calculateNextMoves(positionAfterPortal, Some(lastPortal), currentLevel)
    if (potentialMoves.isEmpty) {
      return minFoundSoFar * 100
    }

    val minTotalSteps = potentialMoves.map { move =>
      val newDepth = move.adjustDepth(currentLevel)
      iterateMovesUntilAtEnd(move, move.stepsAway + stepsAfterTakingPortal, path ++ List(move), newDepth) }.min

    updateMinSoFar(minTotalSteps)

    minTotalSteps
  }

  def onLevelZero(currentLevel: Option[Int]): Boolean = {
    currentLevel.isEmpty || currentLevel.get == 0
  }

  def updateMinSoFar(totalSteps: Int): Unit = {
    if (totalSteps < minFoundSoFar) {
      println(s"** New best: $totalSteps **")
      minFoundSoFar = totalSteps
    }
  }

  def calculateNextMoves(position: Point, lastPortal: Option[Portal], currentLevel: Option[Int]): Vector[PotentialTarget] = {
    val potentialKeys = findAllKeysInRange(position, Set(), 0)

    val distinctKeys = potentialKeys.map(_.portal).distinct
    var distinctTargets = distinctKeys.map(findMinimumDistance(_, potentialKeys))

    val zzRoute = distinctTargets.find { target => target.portal.label == "ZZ" }
    if (zzRoute.isDefined && onLevelZero(currentLevel)) {
      val distance = zzRoute.get.stepsAway
      distinctTargets = distinctTargets.filter { target => target.portal.label == "ZZ" || target.stepsAway < distance }
    }

    if (lastPortal.isDefined) {
      distinctTargets = distinctTargets.filterNot(_.portal == lastPortal.get)
    }

    if (currentLevel.isDefined && currentLevel.get == 0) {
      distinctTargets = distinctTargets.filterNot{ target => target.portal.label != "ZZ" && target.portal.outerPt == target.pt }
    }

    if (currentLevel.isDefined && currentLevel.get != 0) {
      distinctTargets = distinctTargets.filterNot { target => target.portal.label == "ZZ" }
    }

    distinctTargets
  }
  def findMinimumDistance(portal: Portal, potentialRoutes: Vector[PotentialTarget]): PotentialTarget = {
    potentialRoutes.filter(_.portal == portal).minBy(_.stepsAway)
  }

  def findAllKeysInRange(currentPosition: Point, pointsVisited: Set[Point], stepsSoFar: Int): Vector[PotentialTarget] = {
    val ret = ListBuffer[PotentialTarget]()
    val neighbours = getAdjacentSpaces(currentPosition, pointsVisited)

    neighbours.foreach { pt =>
      if (pt == end) {
        ret.addOne(PotentialTarget(Portal("ZZ", end, end), pt, stepsSoFar + 1))
      } else if (portals.exists { portal => portal.outerPt == pt || portal.innerPt == pt }) {
        val portal = portals.find { portal => portal.outerPt == pt || portal.innerPt == pt }.get
        ret.addOne(PotentialTarget(portal, pt, stepsSoFar + 1))
      } else {
        val positionsVisited = pointsVisited ++ List(currentPosition)
        ret.addAll(findAllKeysInRange(pt, positionsVisited, stepsSoFar + 1))
      }
    }

    ret.toVector
  }
  def getNextPosition(currentPosition: Point, direction: Int): Point = {
    direction match {
      case 1 => new Point(currentPosition.x, currentPosition.y - 1)
      case 2 => new Point(currentPosition.x, currentPosition.y + 1)
      case 3 => new Point(currentPosition.x - 1, currentPosition.y)
      case 4 => new Point(currentPosition.x + 1, currentPosition.y)
    }
  }
  def getNeighbours(point: Point): List[Point] = {
    List(getNextPosition(point, 1), getNextPosition(point, 2), getNextPosition(point, 3), getNextPosition(point, 4))
  }

  def getAdjacentSpaces(currentPosition: Point, pointsVisited: Set[Point]): List[Point] = {
    val neighbours = getNeighbours(currentPosition)

    for {
      point <- neighbours
      pointType = maze(point)
      if pointType == '.'
      if !pointsVisited.contains(point)
    } yield point
  }

  def readMap(): mutable.HashMap[Point, Char] = {
    val hmPointToType = new mutable.HashMap[Point, Char]

    for (y <- input.indices) {
      val line = input(y)
      for (x <- line.indices) {
        val char = line.charAt(x)

        hmPointToType.put(new Point(x, y), char)
      }
    }

    hmPointToType
  }


  def get_center(maze: mutable.HashMap[Point, Char]): Point = {
    val xVals = maze.keys.map { pt => pt.x }
    val yVals = maze.keys.map { pt => pt.y }
    val xAvg = xVals.sum / xVals.size
    val yAvg = yVals.sum / yVals.size
    new Point(xAvg.toInt, yAvg.toInt)
  }


  def findPortals(maze: mutable.HashMap[Point, Char], centerPt: Point): (Point, Point, Set[Portal]) = {
    val letterSpaces = maze.filter { tuple => tuple._2.isUpper }
    val dotSpaces = maze.filter { tuple => tuple._2 == '.' }.keySet.toSet
    val portals = mutable.Set[Portal]()

    var start: Point = new Point(0, 0)
    var end: Point = new Point(0, 0)

    val hmPortalToOtherPoint = mutable.HashMap[String, Point]()

    for {
      (point, letter) <- letterSpaces
    } {
      val (label, thisPoint) = parseLabelAndAdjacentPoint(point, letter, letterSpaces, dotSpaces)
      if (label == "AA") {
        start = thisPoint
      } else if (label == "ZZ") {
        end = thisPoint
      }

      if (portals.count(_.label == label) > 0) {
      } else if (hmPortalToOtherPoint.contains(label)) {
        val otherPoint = hmPortalToOtherPoint(label)
        if (thisPoint != otherPoint) {
          portals.add(makePortal(label, thisPoint, otherPoint, centerPt))
        }
      } else {
        hmPortalToOtherPoint.put(label, thisPoint)
      }
    }

    (start, end, portals.toSet)
  }

  def getDistanceBetweenPoints(ptA: Point, ptB: Point): Double = {
    val xLength = Math.abs(ptA.x - ptB.x)
    val yLength = Math.abs(ptA.y - ptB.y)
    Math.sqrt(xLength * xLength + yLength * yLength)
  }

  def makePortal(label: String, ptA: Point, ptB: Point, centerPt: Point): Portal = {
    val distA = getDistanceBetweenPoints(ptA, centerPt)
    val distB = getDistanceBetweenPoints(ptB, centerPt)

    if (distA > distB) {
      Portal(label, ptA, ptB)
    } else {
      Portal(label, ptB, ptA)
    }
  }

  def parseLabelAndAdjacentPoint(letterPoint: Point,
                                         letter: Char,
                                         letterSpaces: mutable.HashMap[Point, Char],
                                         dotSpaces: Set[Point]): (String, Point) = {

    val left = new Point(letterPoint.x - 1, letterPoint.y)
    val right = new Point(letterPoint.x + 1, letterPoint.y)
    val up = new Point(letterPoint.x, letterPoint.y - 1)
    val down = new Point(letterPoint.x, letterPoint.y + 1)

    if (letterSpaces.contains(left)) {
      val label = letterSpaces(left).toString + letter
      (label, findDotSpace(letterPoint, left, dotSpaces))
    } else if (letterSpaces.contains(right)) {
      val label = letter.toString + letterSpaces(right)
      (label, findDotSpace(letterPoint, right, dotSpaces))
    } else if (letterSpaces.contains(up)) {
      val label = letterSpaces(up).toString + letter
      (label, findDotSpace(letterPoint, up, dotSpaces))
    } else {
      val label = letter.toString + letterSpaces(down)
      (label, findDotSpace(letterPoint, down, dotSpaces))
    }
  }

  def findDotSpace(ptA: Point, ptB: Point, dotSpaces: Set[Point]): Point = {
    val xMin = Math.min(ptA.x, ptB.x)
    val xMax = Math.max(ptA.x, ptB.x)
    val yMin = Math.min(ptA.y, ptB.y)
    val yMax = Math.max(ptA.y, ptB.y)

    if (xMin == xMax) {
      if (dotSpaces.contains(new Point(ptA.x, yMin - 1))) {
        new Point(ptA.x, yMin - 1)
      } else {
        new Point(ptA.x, yMax + 1)
      }
    } else {
      if (dotSpaces.contains(new Point(xMin - 1, ptA.y))) {
        new Point(xMin - 1, ptA.y)
      } else {
        new Point(xMax + 1, ptA.y)
      }
    }
  }

  def part1(): Any = {
    val potentialMoves = calculateNextMoves(start, None, None)

    val paths = potentialMoves.map { move =>
      iterateMovesUntilAtEnd(move, move.stepsAway, List(move), None)
    }

    println(s"$paths")

    paths.min
  }

  def part2(): Any = {
    minFoundSoFar = 20000
    val potentialMoves = calculateNextMoves(start, None, Some(0))
    println(s"$potentialMoves")

    val paths = potentialMoves.map { move =>
      val newDepth = move.adjustDepth(Some(0))
      iterateMovesUntilAtEnd(move, move.stepsAway, List(move), newDepth)
    }

    println(s"$paths")

    paths.min
  }
  def main(args: Array[String]): Unit = {
    part1()
    part2()
  }
}
