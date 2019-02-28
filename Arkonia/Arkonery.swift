import Foundation
import SpriteKit

class Arkonery {
    static var aboriginalGenome: Genome { return Assembler.makeRandomGenome(cGenes: 200) }

    var cAliveArkons = 0
    var cArkonBodies = 0
    let dispatchQueue = DispatchQueue(label: "carkonery")
    var pendingGenomes = [Genome]()
    let portal: SKSpriteNode
    var tickAction: SKAction!

    init(portal: SKSpriteNode) { self.portal = portal; portal.speed = 0.25 }

    func launchArkon(parentGenome: Genome) { pendingGenomes.append(parentGenome) }

    func postInit(_ world: World) {
        self.tickAction = SKAction.run({ [unowned self] in self.tick() }, queue: world.dispatchQueue)
    }

    private func makeArkon(parentGenome: Genome) {
        let (newGenome, fNet_) = makeNet(parentGenome: parentGenome)
        guard let fNet = fNet_, !fNet.layers.isEmpty else { return }

        launchpad = Arkon(genome: newGenome, fNet: fNet, portal: portal)
    }

    private func makeNet(parentGenome: Genome) -> (Genome, FNet?) {
        defer { cArkonBodies += 1; cAliveArkons += 1 }

        let newGenome = parentGenome.copy()
        Mutator.shared.mutate(newGenome)

        let e = FDecoder.shared.decode(newGenome)
        return (newGenome, e as? FNet)
    }

    //
    // I'm in the context of the display cycle here, not in carkonery context.
    //
    var launchpad: Arkon?
    func tick() {
        guard let newborn = launchpad else { // Display is ready for a new arkon
            if !pendingGenomes.isEmpty {
                let newGenome = pendingGenomes.removeLast()
                dispatchQueue.async { [weak self] in self?.makeArkon(parentGenome: newGenome) }
            }

            return
        }

        newborn.launch()
        launchpad = nil
    }

}
