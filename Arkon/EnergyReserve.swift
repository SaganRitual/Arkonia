import CoreGraphics

enum EnergyReserveType: CaseIterable {
    case bone, fatReserves, readyEnergyReserves, spawnReserves, stomach
}

class EnergyReserve {
    static let startingLevelBone: CGFloat = 5
    static let startingLevelFat: CGFloat = 15
    static let startingLevelReadyEnergy: CGFloat = 120
    static let spawnReservesCapacity: CGFloat = 200

    static let startingEnergyLevel = (
        startingLevelBone + startingLevelFat + startingLevelReadyEnergy
    )

    var isAmple: Bool { return level >= overflowThreshold }
    var isEmpty: Bool { return level <= 0 }
    var isFull: Bool { return level >= capacity }
    var mass: CGFloat { return level / energyDensity }

    var capacity: CGFloat {                        // in mJ
        get { CGFloat(capacities!.values[hotReserveBucket]) }
        set { capacities!.values[hotReserveBucket] = Double(newValue) }
    }

    let energyDensity: CGFloat                  // in J/g
    let energyReserveType: EnergyReserveType
    let overflowThreshold: CGFloat              // in mJ

    var level: CGFloat {                        // in mJ
        get { CGFloat(levels!.values[hotReserveBucket]) }
        set { levels!.values[hotReserveBucket] = Double(newValue) }
    }

    weak var capacities: HotReserve!
    let hotReserveBucket: Int
    weak var levels: HotReserve!
    let name: String

    init(
        _ type: EnergyReserveType,
        _ capacities: HotReserve,
        _ hotReserveBucket: Int,
        _ levels: HotReserve
    ) {
        self.energyReserveType = type
        self.capacities = capacities
        self.hotReserveBucket = hotReserveBucket
        self.levels = levels

        let level: CGFloat

        switch type {
        case .bone:
            name = "bone"
            energyDensity = 1
            level = EnergyReserve.startingLevelBone
            overflowThreshold = CGFloat.infinity
            capacity = 5

        case .fatReserves:
            name = "fatReserves"
            energyDensity = 8
            level = EnergyReserve.startingLevelFat
            overflowThreshold = 160
            capacity = 160

        case .readyEnergyReserves:
            name = "readyEnergyReserves"
            energyDensity = 4
            level = EnergyReserve.startingLevelReadyEnergy
            overflowThreshold = 100
            capacity = 120

        case .spawnReserves:
            name = "spawnReserves"
            energyDensity = 16
            level = 0
            overflowThreshold = CGFloat.infinity
            capacity = EnergyReserve.spawnReservesCapacity

        case .stomach:
            name = "stomach"
            energyDensity = 2
            level = 0
            overflowThreshold = 0
            capacity = Arkonia.maxMannaEnergyContentInJoules
        }

        self.level = level
    }

    func deposit(_ cJoules: CGFloat) {
        if cJoules <= 0 { return }  // Energy level can go slightly neg, rounding?

        level = min(level + cJoules, capacity)
        Debug.log(level: 89) {
            let js = String(format: "%3.3f", cJoules)
            let Ls = String(format: "%3.3f", level)
            let fs = String(format: "%3.3f%%", level / capacity)

            return "deposit \(js) to \(name), level = \(level), was \(Ls)/\(fs)"
        }
    }

    @discardableResult
    func withdraw(_ cJoules: CGFloat) -> CGFloat {
        if cJoules == 0 { return 0 }
        precondition(cJoules > 0)

        assert(cJoules < CGFloat.infinity)

        let net = min(level, cJoules)
        level -= net

        Debug.log(level: 74) {
            let js = String(format: "%3.3f", cJoules)
            let Ls = String(format: "%3.3f", level)
            let fs = String(format: "%3.3f", level / capacity)
            let ns = String(format: "%3.3f", net)

            return "withdraw \(js)(\(ns)) from \(name), level = \(Ls), fullness = \(fs)"
        }
        return net
    }
}
