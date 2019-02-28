import Foundation
import SpriteKit

extension Foundation.Notification.Name {
    static let arkonIsBorn = Foundation.Notification.Name("arkonIsBorn")
}

class Arkonery {
    static var aboriginalGenome: Genome { return Assembler.makeRandomGenome(cGenes: 200) }
    static var shared: Arkonery!

    var cAliveArkons = 0
    var cArkonBodies = 0
    let dispatchQueue = DispatchQueue(label: "carkonery")
    let notificationCanter = NotificationCenter.default
    var pendingGenomes = [(Int?, Genome)]()
    let portal: SKSpriteNode
    var tickWorkItem: DispatchWorkItem!

    init(portal: SKSpriteNode) {
        self.portal = portal
        portal.speed = 0.1
    }

    func postInit() {
        self.tickWorkItem = DispatchWorkItem { [unowned self] in self.tick() }
    }

    private func makeArkon(parentFishNumber: Int?, parentGenome: Genome) -> Launchpad {
        defer { cArkonBodies += 1 }

        let (newGenome, fNet_) = makeNet(parentGenome: parentGenome)

        guard let fNet = fNet_, !fNet.layers.isEmpty
            else { return .dead(parentFishNumber) }

        guard let arkon = Arkon(genome: newGenome, fNet: fNet, portal: portal)
            else { return .dead(parentFishNumber) }

       return .alive(parentFishNumber, arkon)
    }

    private func makeNet(parentGenome: Genome) -> (Genome, FNet?) {
        defer { cAliveArkons += 1 }

        let newGenome = parentGenome.copy()
        Mutator.shared.mutate(newGenome)

        let e = FDecoder.shared.decode(newGenome)
        return (newGenome, e as? FNet)
    }

    static func reviveSpawner(fishNumber: Int) {
        let n = Foundation.Notification.Name.arkonIsBorn
        NotificationCenter.default.post(
            name: n, object: self, userInfo: ["parentFishNumber": fishNumber]
        )
    }

    func spawn(parentID: Int?, parentGenome: Genome) {
        dispatchQueue.async { [unowned self] in
            let needTick = self.pendingGenomes.isEmpty
            self.pendingGenomes.append((parentID, parentGenome))
            if needTick { self.dispatchQueue.async(execute: self.tickWorkItem) }
        }
    }

    enum Launchpad: Equatable {
        static func == (lhs: Arkonery.Launchpad, rhs: Arkonery.Launchpad) -> Bool {
            func isEmpty(_ theThing: Arkonery.Launchpad) -> Bool {
                switch theThing {
                case .alive: return false
                case .dead: return false
                case .empty: return true
                }
            }

            return isEmpty(lhs) && isEmpty(rhs)
        }

        case alive(Int?, Arkon)
        case dead(Int?)
        case empty
    }

    var launchpad = Launchpad.empty

    func scheduleTick() { dispatchQueue.async(execute: tickWorkItem) }

    func tick() {
        defer { if !pendingGenomes.isEmpty { scheduleTick() } }

        if launchpad != .empty { return }

        let (parentFishNumber, parentGenome) = pendingGenomes.removeFirst()
        let state = makeArkon(parentFishNumber: parentFishNumber, parentGenome: parentGenome)

        switch state {
        case .alive:
            launchpad = state

        case .dead(.none):
            break

        case .dead(.some(let parentFishNumber)):
            Arkonery.reviveSpawner(fishNumber: parentFishNumber)

        // makeArkon() shouldn't return this; it's n/a to arkon state
        case .empty: preconditionFailure()
        }
    }

}
