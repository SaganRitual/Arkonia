import Foundation
import SpriteKit

struct Metabolism {
    static let birthWeight: CGFloat = 1 // How much your offspring weigh
    static let crossover: CGFloat = 1   // This is where health is at 50%
    static let flatness: CGFloat = 1    // Flatness of the slope between dead and healthy

    mutating func absorbGreens(_ mass: CGFloat) {
        hunger -= mass * 0.01 * ArkonFactory.scale
        pBody.mass += mass * 0.01 * ArkonFactory.scale
//        print("absorb green(\(mass)) -> \(pBody.mass),  \(health)")
    }

    mutating func absorbMeat(_ mass: CGFloat) {
        hunger -= mass * 0.05 * ArkonFactory.scale
        self.pBody.mass += mass * 0.5 * ArkonFactory.scale
//        print("absorb meat(\(mass)) -> \(pBody.mass),  \(health)")
    }

    // In Arkonia, we measure energy in arks, because I can't figure out how to
    // go from Newton-seconds to Newton-meters, or whatever.
    mutating func debitEnergy(_ arks: CGFloat) {
        pBody.mass -= arks / 10
        hunger += arks
//        print("debit energy(\(arks)) -> \(pBody.mass),  \(health)")
    }

    mutating func giveBirth() {
        let h = health, m = pBody.mass
        pBody.mass -= Metabolism.birthWeight * ArkonFactory.scale
        print("birth", h, m, health, pBody.mass)
        hunger += Metabolism.birthWeight * ArkonFactory.scale
    }

    private var hunger_: CGFloat = 0
    var hunger: CGFloat { get { return hunger_ } set { hunger_ = max(newValue, 0) } }

    var health: CGFloat {
        guard oxygenLevel > 0 else { return 0 }
        let x = pBody.mass - 0.235
        let y = 0.5 + (x / (2 * sqrt(x * x + 0.001)))
        return y
    }

    // In Arkonia, we measure volume in arks, because they make for easy conversion
    mutating func inhale(_ arks: CGFloat) {
        oxygenLevel += arks
    }

    private var oxygenLevel_: CGFloat = 1.0
    var oxygenLevel: CGFloat {
        get { return oxygenLevel_ }
        set { oxygenLevel_ = constrain(newValue, lo: 0, hi: 1) }
    }

    var pBody: SKPhysicsBody!

    mutating func tick() {
        let oxygenNormalDuration: CGFloat = 2.0
        oxygenLevel -= 1 / (oxygenNormalDuration * 60)
    }
}
