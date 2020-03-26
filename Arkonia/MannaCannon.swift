import SpriteKit

class MannaCannon {
    static var shared: MannaCannon?

    var rebloomDispatch = DispatchQueue(
        label: "ak.manna.rebloom", target: DispatchQueue.global(qos: .userInitiated)
    )

    private(set) var fertileSpots: [FertileSpot]

    var cDeadManna = 0
    var cPhotosynthesizingManna = 0

    init() {
        fertileSpots = (0..<Arkonia.cFertileSpots).map { _ in FertileSpot() }
    }

    func postInit() {
        (0..<Arkonia.cMannaMorsels).forEach { fishNumber in
            let m = Manna(fishNumber)
            m.plant()
        }
    }
}
