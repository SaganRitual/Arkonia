import GameplayKit
import GameKit

enum NetMutation: CaseIterable {
    case dropLayer, duplicateLayer, duplicateAndMutateLayer, insertRandomLayer, mutateCRings
}

struct Mutator {
    static var shared = Mutator()

    mutating func mutate(from value: Float, nextNormal: Float) -> (Float, Bool) {
        // If next normal is zero, we didn't change anything
        return (value + nextNormal, nextNormal != 0)
    }
}

extension Net {
    static func mutateNetParameters(
        _ biases: UnsafeMutablePointer<Float>, _ cBiases: Int,
        _ weights: UnsafeMutablePointer<Float>, _ cWeights: Int
    ) -> Bool {
        var uRandomer = AKRandomer(.uniform)
        var nRandomer = AKRandomer(.normal)
        let oddsOfPerfectClone: Float = 0.85

        if uRandomer.positive() < oddsOfPerfectClone { return true }

        let percentageMutation = uRandomer.inRange(0..<0.1)
        let cMutations = Int(percentageMutation * Float(cBiases + cWeights))
        if cMutations == 0 { return true }

        var isCloneOfParent = true
        for _ in 0..<cMutations {
            let (whichBuffer, offset): (UnsafeMutablePointer<Float>, Int)
            if uRandomer.bool() {
                whichBuffer = biases; offset = uRandomer.inRange(0..<cBiases)
            } else {
                whichBuffer = weights; offset = uRandomer.inRange(0..<cWeights)
            }

            let (newValue, didMutate) = Mutator.shared.mutate(
                from: whichBuffer[offset], nextNormal: nRandomer.next()!
            )

            if didMutate {
                isCloneOfParent = false
                whichBuffer[offset] = newValue
            }
        }

        return isCloneOfParent
    }
}
