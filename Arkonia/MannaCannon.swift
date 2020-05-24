import SpriteKit

class MannaCannon {
    static var shared: MannaCannon?

    static let mannaPlaneQueue = DispatchQueue(
        label: "manna.plane.serial", target: DispatchQueue.global()
    )

    private(set) var readyManna: [Manna]
    let pollenators: [Pollenator]

    var cDeadManna = 0
    var cPhotosynthesizingManna = 0
    var cPlantedManna = 0

    init() {
        readyManna = []

        if Arkonia.cPollenators == 0 { pollenators = []; return }

        // Colors for bone, ham, leather, oxygen, ooze pollenators
        let colors: [SKColor] = [.white, .purple, .yellow, .blue, .green]
        pollenators = colors.map { Pollenator($0) }
    }

    func blast(_ manna: Manna) {
        let targetCLaunchees = 10

        MannaCannon.mannaPlaneQueue.async {
            self.readyManna.append(manna)

            if self.readyManna.count >= targetCLaunchees {
                Debug.log(level: 183) { "blast.0 \(self.readyManna.count), \(targetCLaunchees)" }

                let duration = TimeInterval.random(
                    in: Arkonia.mannaRebloomDelayMinimum..<Arkonia.mannaRebloomDelayMaximum
                )

                let cLaunchees = min(self.readyManna.count, targetCLaunchees)
                let launchees = Array(self.readyManna[0..<cLaunchees])
                self.readyManna.removeFirst(cLaunchees)

                Debug.log(level: 183) { "blast.1 \(self.readyManna.count), \(targetCLaunchees), \(cLaunchees)" }

                MannaCannon.mannaPlaneQueue.asyncAfter(deadline: .now() + duration) {
                    Debug.log(level: 183) { "blast.2 \(self.readyManna.count), \(targetCLaunchees), \(cLaunchees)" }
                    SceneDispatch.shared.schedule {
                        Debug.log(level: 183) { "blast.3 \(self.readyManna.count), \(targetCLaunchees), \(cLaunchees)" }
                        launchees.forEach { $0.rebloom() }
                    }
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
        for fishNumber in 0..<Arkonia.cMannaMorsels {
            if morsel == nil { morsel = Manna(fishNumber) }
            if morsel!.plant() == true {
                cPlantedManna += 1
                morsel = nil
            }
        }
    }
}
