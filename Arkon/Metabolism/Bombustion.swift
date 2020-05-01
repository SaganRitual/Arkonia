import Foundation

// Notice that we need o2 to react with our energy when we withdraw from any
// of the energy reserves

extension Metabolism {
    @discardableResult
    func withdrawEnergy(_ cJoules: CGFloat) -> CGFloat {
        return withdrawEnergy(cJoules, from: ready)
    }

    private func withdrawEnergy(
        _ cJoules: CGFloat, from organ: OozeStorage
    ) -> CGFloat {
        report("wdnrg0")
        let netEnergy = organ.withdraw(cJoules)
        report("wdnrg1")
        if netEnergy > 0 { lungs.combust(netEnergy) }
        report("wdnrg2")
        return netEnergy
    }

    func withdrawFromReadySurplus(_ cJoules: CGFloat) -> CGFloat {
        report("wdsur1")
        let netEnergy = ready.withdrawFromSurplus(max: cJoules)
        if netEnergy > 0 { lungs.combust(netEnergy) }

        Debug.log(level: 174) {
            "cJoules \(cJoules)"
            + ", lungs.level \(lungs.level)"
            + ", netEnergy = \(netEnergy)"
        }

        report("wdsur2")
        return netEnergy
    }

    @discardableResult
    func getEmbryo() -> CGFloat {
        report("wdspn1")
        let netEnergy = spawn.withdraw(spawnCost)
        report("wdspn2")
        return netEnergy
    }

    func withdrawVitamin(_ cVitamins: CGFloat, from organ: DeployableType) -> CGFloat {
//        let netVitamins = ([bone, leather, poison][organ.rawValue]).withdrawVitamin(cVitamins, o2: lungs.level)
//        if netVitamins > 0 { lungs.combust(netVitamins) }
//        report("wdvit ")
//        return netVitamins
        return 0
    }
}
