import SpriteKit

struct Census {
    let rCurrentPopulation: Reportoid
    let rHighWaterPopulation: Reportoid
    let rHighWaterAge: Reportoid
    let ageFormatter: DateComponentsFormatter

    let rOffspring: Reportoid

    init(_ scene: GriddleScene) {
        rCurrentPopulation = scene.reportArkonia.reportoid(2)
        rHighWaterPopulation = scene.reportMisc.reportoid(2)
        rHighWaterAge = scene.reportMisc.reportoid(1)
        ageFormatter = DateComponentsFormatter()

        ageFormatter.allowedUnits = [.minute, .second]
        ageFormatter.allowsFractionalUnits = true
        ageFormatter.unitsStyle = .positional
        ageFormatter.zeroFormattingBehavior = .pad

        rOffspring = scene.reportMisc.reportoid(3)

        updateCensus()
    }

    private func updateCensus() {
        var currentTime: Int = 0
        var liveArkonsAges = [Int]()
        var worldStats: World.StatsCopy!

        func partA() {
            World.stats.getStats(partB)
        }

        func partB(_ worldStats_: World.StatsCopy) {
            worldStats = worldStats_

            let action = SKAction.run { partC(worldStats.currentTime) }

            GriddleScene.arkonsPortal.run(action) {
                if liveArkonsAges.isEmpty { partE() } else { partD() }
            }
        }

        func partC(_ currentTime: Int) {
            liveArkonsAges = GriddleScene.arkonsPortal!.children.compactMap { node in
                guard let sprite = node as? SKSpriteNode else {
                    fatalError()
                }

                guard let stepper = Stepper.getStepper(
                    from: sprite, require: false
                ) else { return nil }

                return  currentTime - stepper.birthday
            }
        }

        func partD() {
            self.rCurrentPopulation.data.text =
                String(worldStats.currentPopulation)

            self.rHighWaterPopulation.data.text =
                String(worldStats.highWaterPopulation)

            self.rOffspring.data.text =
                String(format: "%d", worldStats.highWaterCOffspring)

            rHighWaterAge.data.text =
                ageFormatter.string(from: Double(worldStats.highWaterAge))

            partE()
        }

        func partE() {
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
                partA()
            }
        }

        partA()
    }
}
