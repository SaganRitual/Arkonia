import SpriteKit

class MannaCannon {
    static var shared: MannaCannon?

    var diebackDispatch = DispatchQueue(
        label: "ak.manna.rebloom", target: DispatchQueue.global(qos: .utility)
    )

    private(set) var readyManna: [Manna]
    private(set) var pollenators: [Pollenator]

    var cDeadManna = 0
    var cPhotosynthesizingManna = 0
    var cPlantedManna = 0

    init() {
        pollenators = (0..<Arkonia.cPollenators).map { ss in
            let color = ColorGradient.makeColor(ss, Arkonia.cPollenators * 2)
            return Pollenator(color)
        }

        readyManna = []
    }

    func blast(_ manna: Manna) {
        let targetCLaunchees = 10

        diebackDispatch.async {
            self.readyManna.append(manna)

            if self.readyManna.count >= targetCLaunchees {
                Debug.log(level: 158) { "blast.0 \(self.readyManna.count)" }

                let duration = TimeInterval.random(
                    in: Arkonia.mannaRebloomDelayMinimum..<Arkonia.mannaRebloomDelayMaximum
                )

                let cLaunchees = min(self.readyManna.count, targetCLaunchees)
                let launchees = Array(self.readyManna[0..<cLaunchees])
                self.readyManna.removeFirst(cLaunchees)

                Debug.log(level: 158) { "blast.1 \(self.readyManna.count)" }

                self.diebackDispatch.asyncAfter(deadline: .now() + duration) {
                    launchees.forEach { $0.rebloom() }
                }
            }
        }
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
