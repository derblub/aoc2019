
// https://adventofcode.com/2019/day/14

//    swift main.swift

import Foundation


let FUEL = "FUEL"
let ORE = "ORE"

func load_input(input: String) -> String {
    let current_dir = FileManager.default.currentDirectoryPath
    let file_path = URL(fileURLWithPath: current_dir.appendingPathComponent(input))
    guard let data = try? String(contentsOf: file_path, encoding: .utf8) else {
                print("Error: couldn't read input file")
                exit(1)
            }
        return data
}
let input = load_input(input:"input.txt")


extension Array {
    func chunked(_ chunk: Int) -> [[Element]] {
        stride(from: startIndex, to: endIndex, by: chunk)
            .map { ($0, index($0, offsetBy: chunk, limitedBy: endIndex) ?? endIndex) }
            .map { Array(self[$0 ..< $1]) }
    }
}

struct Material: Equatable {
    var quantity: Int
    var name: String

    func scaled(by scale: Int) -> Material {
        Material(quantity: quantity * scale, name: name)
    }
}

struct Reaction {
    var input: [Material]
    var output: Material
}

func count_ore(fuel_needed fuel: Int, do_reactions reactions: [Reaction]) -> Int {
    var materials_needed: [String: Int] = [FUEL: fuel]
    var excess: [String: Int] = [:]

    while Array(materials_needed.keys) != [ORE] {
        var new_materials: [String: Int] = [:]
        materials_needed.forEach { (name, quantity) in
            guard name != ORE else { excess[ORE, default: 0] += quantity; return }

            var make_quantity = quantity
            if let excess_made = excess[name] {
                if excess_made > make_quantity {
                    excess[name, default: 0] -= make_quantity
                    return
                } else {
                    make_quantity -= excess_made
                    excess.removeValue(forKey: name)
                }
            }

            let reaction = reactions.first(where: { $0.output.name == name })!
            let scale = Int(ceil(Double(make_quantity) / Double(reaction.output.quantity)))
            let inputs_scaled = reaction.input.map { $0.scaled(by: scale) }
            let output_quantity_scaled = reaction.output.quantity * scale

            inputs_scaled.forEach {
                new_materials[$0.name, default: 0] += $0.quantity
            }

            let excess_made = output_quantity_scaled - make_quantity
            if excess_made > 0 {
                excess[name, default: 0] += excess_made
            }
        }

        materials_needed = new_materials
    }

    return materials_needed[ORE]! + excess[ORE, default: 0]
}

let reactions = input
    .split(separator: "\n")
    .map { line -> Reaction in
        let components = line.components(separatedBy: " ")
        let input = Array(components.prefix(while: { $0 != "=>" }))
            .chunked(2)
            .map { words -> Material in
                let quantity = Int(words[0])!
                var name = words[1]
                if name.last == "," { _ = name.removeLast() }
                return Material(quantity: quantity, name: name)
            }
        let output = Material(quantity: Int(components.dropLast().last!)!, name: components.last!)
        return Reaction(input: input, output: output)
    }

func output1() -> String {
    count_ore(fuel_needed: 1, do_reactions: reactions).description
}

func output2() -> String {
    let limit = 1_000_000_000_000
    var inc = 1_000_000
    var fuel = 0

    while true {
        while count_ore(fuel_needed: fuel + inc, do_reactions: reactions) <= limit {
            fuel += inc
        }

        if inc == 1 {
            return fuel.description
        } else {
            inc /= 10
        }
    }
}

print("output: \(output1())")
print("output p2: \(output2())")
