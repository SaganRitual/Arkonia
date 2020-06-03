import GameplayKit

enum NetMutation: CaseIterable {
    case dropLayer, duplicateLayer, duplicateAndMutateLayer, insertRandomLayer, mutateCRings
}

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

        return { return samples.randomElement()! }
    }()

    static func mutate(from value: Float) -> (Float, Bool) {
        // The mutation value is from a normal curve on -1.0..<1.0
        // Add 1/10 of that to the value we got, which should
        // also be in -1.0..<1.0
        let nu = Mutator.mutationValue() / 10
        Debug.log(level: 188) { "from \(value) to \(value + nu) with \(nu)" }

        // If next uniform is zero, we didn't change anything
        return (value + nu, nu != 0)
    }

    static func mutate(from value: Int) -> (Int, Bool) {
        let nu = Mutator.mutationValue() / 10
        let v = Float(value)

        Debug.log(level: 189) { "from \(value) to \(Int(v + nu)) with \(nu)" }

        // If next uniform is zero, we didn't change anything
        return (Int(v + nu), nu != 0)
    }
}
