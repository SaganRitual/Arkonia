import Foundation
import SpriteKit

class Arkonery {
    var aboriginalGenome: Genome { return Assembler.makeRandomGenome(cGenes: 200) }
    let dispatchQueue = DispatchQueue(label: "carkonery")
    var cPendingLaunch = 0
    let portal: SKSpriteNode
    var semaphore = DispatchSemaphore(value: 100)
    var tickAction: SKAction!

    let cArkonSouls = 100
    var cArkonBodies = 0

    init(portal: SKSpriteNode) { self.portal = portal }

    func launchArkon() { cPendingLaunch += 1 }

    func postInit(_ world: World) {
        self.tickAction = SKAction.run({ [unowned self] in self.tick() }, queue: world.dispatchQueue)
    }

    private func makeArkon() {
        cArkonBodies += 1
        let (newGenome, fNet_) = makeNet()
        guard let fNet = fNet_, !fNet.layers.isEmpty else { return }

        launchpad = Arkon(genome: newGenome, fNet: fNet, portal: portal)

        // We've made one arkon, now it's ready to launch. The display cycle
        // will take it from here, and we'll check for more work in our tick()
        isBusy = false
    }

//    static var newGenome: Genome?
    private func makeNet() -> (Genome, FNet?) {
//        if Arkonery.newGenome == nil {
            let newGenome = aboriginalGenome.copy()
            Mutator.shared.mutate(newGenome)
//        }

        let e = FDecoder.shared.decode(newGenome)
        return (newGenome, e as? FNet)
    }

    //
    // I'm in the context of the display cycle here, not in carkonery context.
    //
    var launchpad: Arkon?
    private var isBusy = false  // Only so I know whether to wait to make another arkon
    func tick() {
        if isBusy { return }

        guard let newborn = launchpad else { // Display is ready for a new arkon
            if cPendingLaunch > 0 {
                isBusy = true
                cPendingLaunch -= 1
                dispatchQueue.async { [weak self] in self?.makeArkon() }
            }

            return
        }

        newborn.launch()
        launchpad = nil
    }

}
