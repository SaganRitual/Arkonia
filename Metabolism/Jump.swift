import Foundation

extension Metabolism {
    func applyJumpCosts(_ distance: CGFloat) -> Bool {
        let isAlive: Bool

        let startingMass = self.mass
        let draw = self.mass * distance
        let netEnergy = energy.withdraw(draw)

        defer {
            Debug.log(level: 180) {
                "Jump: \(startingMass) kg, \(distance) meters, requires \(draw) joules, net \(netEnergy); isAlive = \(isAlive)"
            }
        }

        guard netEnergy == draw else { isAlive = false; return isAlive }

        isAlive = lungs.combust(energy: netEnergy)
        return isAlive
    }
}
