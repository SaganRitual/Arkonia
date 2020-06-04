import GameplayKit
import GameKit

enum NetMutation: CaseIterable {
    case dropLayer, duplicateLayer, duplicateAndMutateLayer, insertRandomLayer, mutateCRings
}

struct Mutator {
    static var shared = Mutator()

    let histogram = Debug.Histogram()

    func mutate(from value: Float) -> (Float, Bool) {
        let nu = AKRandom.shared.next()

        // If next uniform is zero, we didn't change anything
        return (value + nu, nu != 0)
    }
}
