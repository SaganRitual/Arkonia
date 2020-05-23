import GameplayKit

enum Mutator {
    // Mutation amounts, zero-centered and spread out over a fast and loose normal curve generator
    static let mutationValue: (() -> Float) = {
        let samples: [Float] = stride(from: -1.0, to: 1.0, by: 0.001).map {
            let sign = Float(abs($0) / $0)
            let sSquared = Double($0 * $0)
            let eee: Double = exp(-sqrt(2 * Double.pi) * sSquared / 1.5)
            let curve = Float(eee)
            let flipped = sign * (1 - curve)
            let result = (flipped < 1.0) ? flipped : flipped - 1e-6  // We don't like 1.0
            return result
        }

        return { return Arkonia.randomElement(in: samples) / 10 }
    }()

    static func mutateNetStrand(parentStrand p: [Float]?, targetLength: Int, value: Float? = nil) -> ([Float], Bool) {
        if let parentStrand = p {
            let (fp, didMutate) = mutateRandomDoubles(parentStrand)
            if let firstPass = fp {

                let c = firstPass.count

                if c > targetLength {
                    return (Array(firstPass.prefix(targetLength)), didMutate)
                } else if c < targetLength {
                    let n = Float(-1), p = Float(1)
                    return (firstPass + (c..<targetLength).map { _ in Arkonia.random(in: n..<p) }, didMutate)
                }

                return (firstPass, didMutate)
            }
        }

        let (lo, hi): (Int, Int) = (value == nil) ? (-1, 1) : ((value! == 0) ? (0, 0) : (-1, 1))
        let fromScratch: [Float] = (0..<targetLength).map { _ in Float(Arkonia.random(in: lo...hi)) }

        Debug.log(level: 93) { "Generate from scratch = \(fromScratch)" }
        return (fromScratch, false)
    }

    // Not sure this is a good mutation. It basically restructures the entire
    // hidden net. Even the smallest change makes the offspring a completely
    // different creature
    static func mutateNetStructure(_ layers: [Int]) -> ([Int], Bool) {
        var didMutate = false

        // 70% chance that the structure won't change at all
        if Arkonia.random(in: 0..<100) < 70 {
            Debug.log(level: 121) { "no mutation to net structure" }
            return (layers, didMutate)
        }

        Debug.log(level: 121) { "mutating net structure" }

        let strippedNetStructure = Array(layers.dropFirst())
        var newNetStructure: [Int]

        switch NetMutation.allCases.randomElement(using: &Arkonia.rng) {
        case .passThru:           newNetStructure = strippedNetStructure
        case .addRandomLayer:     newNetStructure = addRandomLayer(strippedNetStructure)
        case .dropLayer:          newNetStructure = dropLayer(strippedNetStructure)
        case .none:               fatalError()
        }

        if newNetStructure.isEmpty { newNetStructure.append(Arkonia.cMotorNeurons) }

        didMutate = newNetStructure != strippedNetStructure

        newNetStructure.insert(Arkonia.cSenseNeurons, at: 0)
        newNetStructure.append(Arkonia.cMotorNeurons)

        return (newNetStructure, didMutate)
    }
}

private extension Mutator {

    static func mutateRandomDoubles(_ inDoubles: [Float]) -> ([Float]?, Bool) {
        var didMutate = false
        if Arkonia.random(in: 0..<100) < 75 { return (inDoubles, didMutate) }

        let b = Arkonia.random(in: 0..<0.05)
        var cMutate = b * Double(inDoubles.count)  // max 5% of genome

        let i = Int(cMutate)
        if i == 0 && Arkonia.randomBool() {
            Debug.log(level: 121) { "no mutation" }
            return (nil, false)
        }

        cMutate = Double(i) + ((i == 0) ? 1 : 0)
        var outDoubles = inDoubles

        while cMutate > 0 {
            let wherefore = Arkonia.random(in: 0..<inDoubles.count)

            let (newValue, dm) = mutate(from: inDoubles[wherefore])
            if dm { didMutate = true }

            outDoubles[wherefore] = newValue

            cMutate -= 1
        }

        return (outDoubles, didMutate)
    }

    static func mutate(from value: Float) -> (Float, Bool) {
        let nu = Mutator.mutationValue()
        Debug.log(level: 154) { "from \(value) to \(value + nu) with \(nu)" }

        // If next uniform is zero, we didn't change anything
        return (value + nu, nu != 0)
    }

    enum NetMutation: CaseIterable {
        case passThru, addRandomLayer, dropLayer
    }
}

private extension Mutator {
    static func addRandomLayer(_ layers: [Int]) -> [Int] {
        var toMutate = layers

        let insertPoint = Arkonia.random(in: 0..<toMutate.count)
        let cNeurons = Arkonia.random(in: toMutate.min()!..<toMutate.max()!)

        toMutate.insert(cNeurons, at: insertPoint)

        Debug.log(level: 120) { "addRandomLayer to \(layers.count)-layer net: \(cNeurons) neurons, insert at \(insertPoint)" }
        return toMutate
    }

    static func dropLayer(_ layers: [Int]) -> [Int] {
        var toMutate = layers

        let dropPoint = Arkonia.random(in: 0..<toMutate.count)
        toMutate.remove(at: dropPoint)
        Debug.log(level: 120) { "dropLayer from \(layers.count)-layer net, at \(dropPoint)" }

        return toMutate
    }
}
