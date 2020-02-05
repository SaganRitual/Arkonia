import CoreGraphics

enum EnergyReserveType: CaseIterable {
    case bone, fatReserves, readyEnergyReserves, spawnReserves, stomach
}

class EnergyReserve {
    static let startingLevelBone: CGFloat = 5
    static let startingLevelFat: CGFloat = 15
    static let startingLevelReadyEnergy: CGFloat = 120
    static let spawnReservesCapacity: CGFloat = 160

    static let startingEnergyLevel = (
        startingLevelBone + startingLevelFat + startingLevelReadyEnergy
    )

    var isAmple: Bool { return level >= overflowThreshold }
    var isEmpty: Bool { return level <= 0 }
    var isFull: Bool { return level >= capacity }
    var mass: CGFloat { return level / energyDensity }

    let capacity: CGFloat                       // in mJ
    let energyDensity: CGFloat                  // in J/g
    let energyReserveType: EnergyReserveType
    let overflowThreshold: CGFloat              // in mJ

    var level: CGFloat = 0                      // in mJ
    let name: String

    init(_ type: EnergyReserveType) {
        self.energyReserveType = type

        let level: CGFloat

        switch type {
        case .bone:
            name = "bone"
            capacity = 5
            energyDensity = 1
            level = EnergyReserve.startingLevelBone
            overflowThreshold = CGFloat.infinity

        case .fatReserves:
            name = "fatReserves"
            capacity = 160
            energyDensity = 8
            level = EnergyReserve.startingLevelFat
            overflowThreshold = 160

        case .readyEnergyReserves:
            name = "readyEnergyReserves"
            capacity = 120
            energyDensity = 4
            level = EnergyReserve.startingLevelReadyEnergy
            overflowThreshold = 100

        case .spawnReserves:
            name = "spawnReserves"
            capacity = 160
            energyDensity = 16
            level = 0
            overflowThreshold = CGFloat.infinity

        case .stomach:
            name = "stomach"
            capacity = Arkonia.maxMannaEnergyContentInJoules
            energyDensity = 2
            level = 0
            overflowThreshold = 0
        }

        self.level = level
    }

    func deposit(_ cJoules: CGFloat) {
        if cJoules <= 0 { return }  // Energy level can go slightly neg, rounding?

        let js = String(format: "%3.3f", cJoules)
        let Ls = String(format: "%3.3f", level)
        let fs = String(format: "%3.3f%%", level / capacity)
        level = min(level + cJoules, capacity)
        Debug.log(level: 89) { "deposit \(js) to \(name), level = \(level), was \(Ls)/\(fs)" }
    }

    @discardableResult
    func withdraw(_ cJoules: CGFloat) -> CGFloat {
        if cJoules == 0 { return 0 }
        precondition(cJoules > 0)

        assert(cJoules < CGFloat.infinity)

        let net = min(level, cJoules)
        level -= net

        let js = String(format: "%3.3f", cJoules)
        let Ls = String(format: "%3.3f", level)
        let fs = String(format: "%3.3f", level / capacity)
        let ns = String(format: "%3.3f", net)
        Debug.log(level: 74) { "withdraw \(js)(\(ns)) from \(name), level = \(Ls), fullness = \(fs)" }
        return net
    }
}
