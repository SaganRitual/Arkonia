import Foundation
import SpriteKit

struct Metabolism {
    static let birthWeight: CGFloat = 1 // How much your offspring weigh
    static let crossover: CGFloat = 1   // This is where health is at 50%
    static let flatness: CGFloat = 2    // Flatness of the slope between dead and healthy

    mutating func absorbGreens(_ mass: CGFloat) {
        hunger -= mass * 1.0 * ArkonFactory.scale
        pBody.mass += mass * 0.1 * ArkonFactory.scale
    }

    mutating func absorbMeat(_ mass: CGFloat) {
        hunger -= mass * 5.0 * ArkonFactory.scale
        self.pBody.mass += mass * 0.5 * ArkonFactory.scale
    }

    // In Arkonia, we measure energy in arks, because I can't figure out how to
    // go from Newton-seconds to Newton-meters, or whatever.
    mutating func debitEnergy(_ arks: CGFloat) {
        pBody.mass -= arks / 10
        hunger += arks
    }

    mutating func giveBirth() {
        pBody.mass -= Metabolism.birthWeight
        hunger += Metabolism.birthWeight * ArkonFactory.scale
    }

    private var hunger_: CGFloat = 0
    var hunger: CGFloat { get { return hunger_ } set { hunger_ = max(newValue, 0) } }

    var health: CGFloat {
        guard oxygenLevel > 0 else { return 0 }
        let x = pBody.mass - Metabolism.crossover
        let y = 0.5 + (x / (2 * sqrt(x * x + Metabolism.flatness)))
        return y
    }

    // In Arkonia, we measure volume in arks, because they make for easy conversion
    mutating func inhale(_ arks: CGFloat) {
        oxygenLevel += arks
    }

    private var oxygenLevel_: CGFloat = 1.0
    var oxygenLevel: CGFloat { get { return oxygenLevel_ } set { oxygenLevel_ = min(newValue, 1) } }

    var pBody: SKPhysicsBody!

    mutating func tick() {
        oxygenLevel -= 0.005
    }
}
