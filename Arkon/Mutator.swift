import GameplayKit
import GameKit

enum NetMutation: CaseIterable {
    case dropLayer, duplicateLayer, duplicateAndMutateLayer, insertRandomLayer, mutateCRings
}

struct Mutator {
    static var shared = Mutator()

    let histogram = Debug.Histogram()
    var randomer = AKRandomer(.normal)

    mutating func mutate(from value: Float) -> (Float, Bool) {
        let nu = randomer.next()!

        // If next uniform is zero, we didn't change anything
        return (value + nu, nu != 0)
    }
}

extension Net {
    static func mutateNetParameters(
        _ biases: UnsafeMutablePointer<Float>, _ cBiases: Int,
        _ weights: UnsafeMutablePointer<Float>, _ cWeights: Int
    ) -> Bool {
        var randomer = AKRandomer(.uniform)
        let oddsOfPerfectClone: Float = 0.85

        if randomer.positive() < oddsOfPerfectClone { return true }

        let percentageMutation = randomer.inRange(0..<0.1)
        let cMutations = Int(percentageMutation * Float(cBiases + cWeights))
        if cMutations == 0 { return true }

        var isCloneOfParent = true
        for _ in 0..<cMutations {
            let (whichBuffer, offset): (UnsafeMutablePointer<Float>, Int)
            if randomer.bool() {
                whichBuffer = biases; offset = randomer.inRange(0..<cBiases)
            } else {
                whichBuffer = weights; offset = randomer.inRange(0..<cWeights)
            }

            let (newValue, didMutate) = Mutator.shared.mutate(from: whichBuffer[offset])
            if didMutate {
                isCloneOfParent = false
                whichBuffer[offset] = newValue
            }
        }

        return isCloneOfParent
    }
}
