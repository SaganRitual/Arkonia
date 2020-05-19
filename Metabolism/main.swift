import Foundation

enum RandomJumpDistance {
    static let zeroSquared = CGFloat.zero, oneSquared = CGFloat(1), twoSquared = CGFloat(4), threeSquared = CGFloat(9)
    static let jumpDistancesInCellUnits: [CGFloat] = [
        sqrt(zeroSquared + zeroSquared),
        sqrt(zeroSquared + oneSquared), sqrt(oneSquared + oneSquared),
        sqrt(zeroSquared + twoSquared), sqrt(oneSquared + twoSquared), sqrt(twoSquared + twoSquared),
        sqrt(zeroSquared + threeSquared), sqrt(oneSquared + threeSquared), sqrt(twoSquared + threeSquared), sqrt(threeSquared + threeSquared)
    ]

    static func inMeters() -> CGFloat { jumpDistancesInCellUnits.randomElement()! / RealWorldConversions.cellsPerRealMeter }
}

func energyBudget(_ metabolism: Metabolism, _ passCounter: Int) -> Bool {
    Debug.log(level: 179) { "post-init(\(passCounter))" }

    metabolism.digest()

    Debug.log(level: 179) { "post-digest(\(passCounter))" }

    var isAlive = metabolism.applyFixedMetabolicCosts()

    Debug.log(level: 180) { "post-metabolize(\(passCounter)), isAlive = \(isAlive)" }
    if !isAlive { return false }

    let jumpDistance = RandomJumpDistance.inMeters()
    isAlive = metabolism.applyJumpCosts(jumpDistance)
    if !isAlive { return false }

    Debug.log(level: 180) { "post-jump(\(passCounter)), isAlive = \(isAlive)" }

    if Int.random(in: 0..<100) < 25 {
        metabolism.eat()
        Debug.log(level: 180) { "post-eat; mass \(metabolism.mass)" }
    }

    return true
}

let metabolism = Metabolism(cNeurons: 300)
for i in 0..<100 { if energyBudget(metabolism, i) == false { break } }
Debug.waitForLogToClear()
