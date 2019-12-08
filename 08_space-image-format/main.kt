// https://adventofcode.com/2019/day/8

//   kotlinc main.kt -include-runtime -d main.jar && java -jar main.jar


import java.io.File

fun getContents(fileName: String): String = File("./$fileName").readText(Charsets.UTF_8)

fun Any.print() = println(this)

fun runChecksum(data: List<Int>) =
    countValue(data, 1) * countValue(data, 2)

fun countValue(data: List<Int>, value: Int): Int = data.filter { it == value }.count()

fun intStringToIntList(intstr: String) = intstr.map(Character::getNumericValue)

fun main(args: Array<String>) {
    val width = 25
    val height = 6
    Main.part1(width, height)
    Main.part2(width, height)
}

object Main {
    fun part1(width: Int, height: Int) {
        var layers = intStringToIntList(getContents("input.txt")).chunked(width * height)
        val layersSorted = layers.map { Pair(countValue(it, 0), runChecksum(it)) }
        val leastZeros = layersSorted.minBy { it.first }?.second ?: -99
        leastZeros.print()
    }

    fun part2(width: Int, height: Int) {
        val layers = getContents("input.txt").chunked(width * height)
        val image: MutableMap<Int, Char> = HashMap() //use a map so we get putIfAbsent
        layers.forEach {
            layer -> layer.forEachIndexed { index, c -> if (c == '0' || c == '1') image.putIfAbsent(index, c) }
        }
        image.map {
                    when(it.value) {
                        '0' -> ' '
                        '1' -> 	'\u25A0'
                        else -> throw RuntimeException("Error: decoding failed")
                    }
                }
                .joinToString(separator = "")
                .chunked(width)
                .forEach { it.print() }
    }
}
