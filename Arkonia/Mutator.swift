import GameplayKit

enum Mutator {
    // Mutation amounts, zero-centered and spread out over a fast and loose normal curve generator
    static let mutationValue: (() -> Double) = {
        let samples: [Double] = stride(from: -1.0, to: 1.0, by: 0.001).map {
            let sign = abs($0) / $0
            let curve: Double = exp(-sqrt(2 * Double.pi) * $0 * $0 / 1.5)
            let flipped = sign * (1 - curve)
            let result = (flipped < 1.0) ? flipped : flipped - 1e-6  // We don't like 1.0
            return result
        }

        return { return samples.randomElement()! / 10.0 }
    }()

    static func mutateNetStrand(parentStrand p: [Double]?, targetLength: Int) -> ([Double], Bool) {
        if let parentStrand = p {
            let (fp, didMutate) = mutateRandomDoubles(parentStrand)
            if let firstPass = fp {

                let c = firstPass.count

                if c > targetLength {
                    return (Array(firstPass.prefix(targetLength)), didMutate)
                } else if c < targetLength {
                    return (firstPass + (c..<targetLength).map { _ in Double.random(in: -1..<1) }, didMutate)
                }

                return (firstPass, didMutate)
            }
        }

        let fromScratch: [Double] = (0..<targetLength).map { _ in Double.random(in: -1..<1) }
        Debug.log(level: 93) { "Generate from scratch = \(fromScratch)" }
        return (fromScratch, false)
    }

    static func mutateNetStructure(_ layers: [Int]) -> ([Int], Bool) {
        var didMutate = false

        // 80% chance that the structure won't change at all
        if Int.random(in: 0..<100) < 80 {
            Debug.log(level: 121) { "no mutation to net structure" }
            return (layers, didMutate)
        }

        Debug.log(level: 121) { "mutating net structure" }

        didMutate = true

        let strippedNet = Array(layers.dropFirst())
        var newNet: [Int]

        switch NetMutation.allCases.randomElement() {
        case .passThru:           newNet = strippedNet
        case .addDuplicatedLayer: newNet = addDuplicatedLayer(strippedNet)
        case .addMutatedLayer:    newNet = addMutatedLayer(strippedNet)
        case .addRandomLayer:     newNet = addRandomLayer(strippedNet)
        case .dropLayer:          newNet = dropLayer(strippedNet)
        case .none:               fatalError()
        }

        if newNet.isEmpty { newNet.append(Arkonia.cMotorNeurons) }

        newNet.insert(Arkonia.cSenseNeurons, at: 0)
        newNet.append(Arkonia.cMotorNeurons)

        return (newNet, didMutate)
    }
}

private extension Mutator {

    static func mutateRandomDoubles(_ inDoubles: [Double]) -> ([Double]?, Bool) {
        var didMutate = false
        if Int.random(in: 0..<100) < 75 { return (inDoubles, didMutate) }

        let b = Double.random(in: 0..<0.05)
        var cMutate = b * Double(inDoubles.count)  // max 5% of genome

        let i = Int(cMutate)
        if i == 0 && Bool.random() {
            Debug.log(level: 121) { "no mutation" }
            return (nil, false)
        }

        cMutate = Double(i) + ((i == 0) ? 1 : 0)
        var outDoubles = inDoubles
//        var debugMessage = ""

        while cMutate > 0 {
            let wherefore = Int.random(in: 0..<inDoubles.count)

            let (newValue, dm) = mutate(from: inDoubles[wherefore])
            if dm { didMutate = true }

            outDoubles[wherefore] = newValue

//            Debug.log(level: 121) {
//                debugMessage += "at \(wherefore) from \(inDoubles[wherefore]) to \(mutated); "
//                return nil  // Don't log anything; that will happen at the end
//            }

            cMutate -= 1
        }

//        Debug.log(level: 121) { return debugMessage.isEmpty ? nil : "Mutations(\(b)): \(debugMessage)" }
        return (outDoubles, didMutate)
    }

    static func mutate(from value: Double) -> (Double, Bool) {
        let nu = Mutator.mutationValue()
        Debug.log(level: 154) { "from \(value) to \(value + nu) with \(nu)" }

        // If next uniform is zero, we didn't change anything
        return (value + nu, nu != 0)
    }

    enum NetMutation: CaseIterable {
        case passThru, addDuplicatedLayer, addMutatedLayer, addRandomLayer, dropLayer
    }
}

private extension Mutator {

    static func addDuplicatedLayer(_ layers: [Int]) -> [Int] {
        let layerToDuplicate = layers.randomElement()
        let insertPoint = Int.random(in: 0..<layers.count)
        var toMutate = layers
        toMutate.insert(layerToDuplicate!, at: insertPoint)

        Debug.log(level: 120) { "addDuplicatedLayer to \(layers.count)-layer net: \(layerToDuplicate!) neurons, insert at \(insertPoint)" }
        return toMutate
    }

    static func addMutatedLayer(_ layers: [Int]) -> [Int] {
        let layerToMutate = layers.randomElement()
        let insertPoint = Int.random(in: 0..<layers.count)
        var structureToMutate = layers
        let mag = Int.random(in: 1..<2)
        let sign = Bool.random() ? 1 : -1
        let L = abs(layerToMutate! + sign * mag)
        let mutatedLayer = (L == 0) ? 1 : L

        structureToMutate.insert(mutatedLayer, at: insertPoint)

        Debug.log(level: 120) { "addMutatedLayer to \(layers.count)-layer net: \(layerToMutate!) neurons, insert at \(insertPoint)" }
        return structureToMutate
    }

    static func addRandomLayer(_ layers: [Int]) -> [Int] {
        let insertPoint = Int.random(in: 0..<layers.count)
        var toMutate = layers
        let cNeurons = Int.random(in: 1..<10)
        toMutate.insert(cNeurons, at: insertPoint)
        Debug.log(level: 120) { "addRandomLayer to \(layers.count)-layer net: \(cNeurons) neurons, insert at \(insertPoint)" }
        return toMutate
    }

    static func dropLayer(_ layers: [Int]) -> [Int] {
        let howMany = Int.random(in: 0..<layers.count)
        var toMutate = layers

        for _ in 0..<howMany {
            let dropPoint = Int.random(in: 0..<toMutate.count)
            toMutate.remove(at: dropPoint)
            Debug.log(level: 120) { "dropLayer from \(layers.count)-layer net, at \(dropPoint)" }
        }

        return toMutate
    }
}
