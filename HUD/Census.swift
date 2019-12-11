import SpriteKit

class Census {
    let ageFormatter: DateComponentsFormatter
    let currentTime: Int = 0
    let rCurrentPopulation: Reportoid
    let rHighWaterAge: Reportoid
    let rHighWaterPopulation: Reportoid
    let rOffspring: Reportoid
    var worldStats: World.StatsCopy!

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

    private func updateCensus() { partA() }

    private func partA() {
        Grid.shared.serialQueue.asyncAfter(deadline: DispatchTime.now() + 1) {
            World.stats.getStats_ {
                self.worldStats = $0
                self.partB()
            }
        }
    }

    private func partB() {
        let liveArkons: [Stepper] = GriddleScene.arkonsPortal!.children.compactMap { node in
            guard let sprite = node as? SKSpriteNode else { return nil }

            guard let stepper = sprite.getStepper(require: false) else { return nil }
            return stepper
        }.sorted {
            lStepper, rStepper in

            let lAge = CGFloat(lStepper.getAge(worldStats.currentTime))
            let rAge = CGFloat(rStepper.getAge(worldStats.currentTime))

            let lOffspring = CGFloat(lStepper.cOffspring)
            let rOffspring = CGFloat(rStepper.cOffspring)

            return (lAge / (lOffspring + 1)) < (rAge / (rOffspring + 1))
        }

        if liveArkons.isEmpty { for _ in 0..<20 { Dispatch().spawn() } }

//        else if liveArkons.count < 20 {
//            guard let bestBreeder = liveArkons.first else { preconditionFailure() }
//
//            let newNet = Net(
//                parentBiases: bestBreeder.net.biases,
//                parentWeights: bestBreeder.net.weights,
//                layers: bestBreeder.parentLayers,
//                parentActivator: bestBreeder.parentActivator
//            )
//
//            Log.L.write("layers: \(six(bestBreeder.name)) \(bestBreeder.parentLayers ?? [])", level: 33)
//            Dispatch(parentNet: newNet).spawn()
//            Dispatch(parentNet: newNet).spawn()
//            Dispatch().spawn()
//            Dispatch().spawn()
//            Dispatch(parentNet: newNet).spawn()
//            Dispatch(parentNet: newNet).spawn()
//        } else {
//            Log.L.write("liveArkons.count = \(liveArkons.count)", level: 33)
//        }

        if liveArkons.isEmpty { partA() } else { partC() }
    }

    private func partC() {
        self.rCurrentPopulation.data.text =
            String(worldStats.currentPopulation)

        self.rHighWaterPopulation.data.text =
            String(worldStats.highWaterPopulation)

        self.rOffspring.data.text =
            String(format: "%d", worldStats.highWaterCOffspring)

        rHighWaterAge.data.text =
            ageFormatter.string(from: Double(worldStats.highWaterAge))

        partA()
    }
}
