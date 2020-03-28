import SpriteKit

class MannaCannon {
    static var shared: MannaCannon?

    var rebloomDispatch = DispatchQueue(
        label: "ak.manna.rebloom", target: DispatchQueue.global(qos: .userInitiated)
    )

    private(set) var fertileSpots: [FertileSpot]

    var cDeadManna = 0
    var cPhotosynthesizingManna = 0
    var cPlantedManna = 0

    init() {
        fertileSpots = (0..<Arkonia.cFertileSpots).map { _ in FertileSpot() }
    }

    func postInit() {
        // Indiscriminately attempt to plant as many manna as indicated, but
        // down below, we get a random cell, and if it's already occupied, we
        // don't bother it, instead we count that as a bona fide attempt, and
        // use the unplanted manna for the next plant attempt. So we'll typically
        // not end up with cMannaMorsels planted
        var morsel: Manna?
        (0..<Arkonia.cMannaMorsels).forEach { fishNumber in
            if morsel == nil { morsel = Manna(fishNumber) }
            if morsel!.plant() == true { cPlantedManna += 1; morsel = nil }
        }
    }
}
