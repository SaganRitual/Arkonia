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
        var currentTime: TimeInterval = 0

        func partA() {
            World.shared.getPopulation { ps in
                guard let popStats = ps else { fatalError() }

                let currentPop = popStats[0]
                let highWaterPop = popStats[1]
                let highWaterOffspring = popStats[2]

                self.rCurrentPopulation.data.text = String(currentPop)
                self.rHighWaterPopulation.data.text = String(highWaterPop)
                self.rOffspring.data.text = String(format: "%d", highWaterOffspring)
                partB()
            }
        }

        func partB() {
            World.shared.getCurrentTime { cts in
                guard let ct = cts?[0] else { fatalError() }
                currentTime = ct
                partC()
            }
        }

        func partC() {
            let liveArkonsAges: [TimeInterval] =
                Arkon.arkonsPortal!.children.compactMap {
                    let stepper = ($0 as? SKSpriteNode)?.optionalStepper
                    let birthday = stepper?.core.selectoid.birthday ?? 0

                    return  currentTime - birthday
            }

            World.shared.setMaxLivingAge(to: liveArkonsAges.max() ?? 0) { ageses in
                guard let ages = ageses else { fatalError() }
                let maxLivingAge = ages[0]
                let highWaterAge = ages[1]
                partD(maxLivingAge, highWaterAge)
            }
        }

        func partD(_ maxLivingAge: TimeInterval, _ highWaterAge: TimeInterval) {
            rHighWaterAge.data.text =
                ageFormatter.string(from: Double(highWaterAge))

            asyncQueue.asyncAfter(deadline: DispatchTime.now() + 1, execute: partA)
        }

        partA()
    }
}
