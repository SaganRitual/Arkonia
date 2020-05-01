import Foundation

class Metabolism {
    let bone:    Deployable
    let fat:     OozeStorage
    let leather: Deployable
    let lungs:   Lungs
    let poison:  Deployable
    let ready:   ReadyEnergy
    let spawn:   OozeStorage
    let stomach: Stomach

    #if DEBUG
    var mostRecentCycleStartTime = UInt64(0)
    var overTimeLimitCount = 0
    #endif

    let allOrgans: [Reportable]

    var asphyxiation: CGFloat { 1 - lungs.fullness }
    var canSpawn:     Bool    {  Debug.log(level: 175) { "spawn.level = \(spawn.level), spawnCost = \(spawnCost)" }; return spawn.level >= spawnCost }
    var hunger:       CGFloat { 1 - stomach.fullness }
    var mass:         CGFloat { allOrgans.reduce(0) { $0 + $1.mass } }
    var spawnCost:    CGFloat {
        ready.capacity * EnergyBudget.Ready.densityKgPerJoule // Ugly -- should separate ham and o2 costs, or have a more sensible ingredients combination
            + lungs.capacity * EnergyBudget.Lungs.mfgCostJoulesPerCCcap * EnergyBudget.Ready.densityKgPerJoule
    }

    func report(_ label: String) {
        Debug.log(level: 174) {
            var exhausted = String()

            let organs: [Reportable] = [fat, lungs, ready, spawn, stomach]

            let line = organs.reduce(into: String()) {
                let s1 = String(format: "%3.6f", $1.level).padding(toLength: 8, withPad: " ", startingAt: 0)
                let s2 = String(format: "%3.6f", $1.mass).padding(toLength: 8, withPad: " ", startingAt: 0)

                $0 += "\(s1) - \(s2)   "

                if $1.level <= 0 {
                    switch $1 {
                    case is Lungs:       exhausted += "\nOUT OF OXYGEN\n"
                    case is ReadyEnergy: exhausted += "\nREADY RESERVES EMPTY\n"
                    default: break
                    }
                }
            }

            let s3 = String(format: "%3.6f", mass).padding(toLength: 8, withPad: " ", startingAt: 0)
            return "\(label): " + line + "Arkon mass \(s3)" + exhausted
        }
    }

    internal init() {
        self.bone = Deployable(type: .bone)
        self.leather = Deployable(type: .leather)
        self.poison = Deployable(type: .poison)

        self.lungs = Lungs()
        self.ready = ReadyEnergy()
        self.stomach = Stomach()

        self.fat = OozeStorage(
            capacity: EnergyBudget.Fat.capacityKg,
            density: EnergyBudget.Fat.densityKgPerJoule,
            medium: .meat,
            overflowFullness: EnergyBudget.Fat.overflowFullness
        )

        self.spawn = OozeStorage(
            capacity: EnergyBudget.Spawn.capacityKg,
            density: EnergyBudget.Spawn.densityKgPerJoule,
            medium: .meat
        )

        self.allOrgans = [
            bone, leather, lungs, poison, ready, spawn, stomach
        ]

        self.ready.deposit(EnergyBudget.Ready.initialValue)
        self.lungs.deposit(EnergyBudget.Lungs.initialValue)
    }
}
