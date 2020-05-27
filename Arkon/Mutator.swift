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

        return { return samples.randomElement()! / 10 }
    }()

    static func mutate(from value: Float) -> (Float, Bool) {
        let nu = Mutator.mutationValue()
        Debug.log(level: 184) { "from \(value) to \(value + nu) with \(nu)" }

        // If next uniform is zero, we didn't change anything
        return (value + nu, nu != 0)
    }

    static func mutate(from value: Int) -> (Int, Bool) {
        let nu = Mutator.mutationValue()
        let v = Float(value)

        Debug.log(level: 184) { "from \(v) to \(v + nu) with \(nu)" }

        // If next uniform is zero, we didn't change anything
        return (Int(v + nu), nu != 0)
    }
}
