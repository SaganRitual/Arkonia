import Foundation
import SpriteKit

struct Metabolism {
    static let birthWeight: CGFloat = 1 * ArkonFactory.scale // How much your offspring weigh

    mutating func absorbGreens(_ mass: CGFloat) {
        let foodValue = mass / 8
        self.pBody.mass += foodValue
    }

    mutating func absorbMeat(_ mass: CGFloat) {
        let foodValue = mass / 4
        self.pBody.mass += foodValue
    }

    // In Arkonia, we measure energy in arks, because I can't figure out how to
    // go from Newton-seconds to Newton-meters, or whatever.
    mutating func debitEnergy(_ arks: CGFloat) {
        pBody.mass -= arks / 8
//        print("debit energy(\(arks)) -> \(pBody.mass),  \(health)")
    }

    mutating func giveBirth() { pBody.mass -= Metabolism.birthWeight }

    var health: CGFloat {
        guard oxygenLevel > 0 else { return 0 }
        let x = pBody.mass - 0.235
        let y = 0.5 + (x / (2 * sqrt(x * x + 0.001)))
        return y
    }

    // In Arkonia, we measure volume in arks, because they make for easy conversion
    mutating func inhale(_ arks: CGFloat) {
        oxygenLevel += arks / 2
    }

    private var oxygenLevel_: CGFloat = 1.0
    var oxygenLevel: CGFloat {
        get { return oxygenLevel_ }
        set { oxygenLevel_ = constrain(newValue, lo: 0, hi: 1) }
    }

    weak var pBody: SKPhysicsBody!

    mutating func tick() {
        let oxygenNormalDuration: CGFloat = 2.0
        oxygenLevel -= 1 / (oxygenNormalDuration * 60)
    }
}
