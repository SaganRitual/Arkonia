import Foundation
import SpriteKit

extension Foundation.Notification.Name {
    static let arkonIsBorn = Foundation.Notification.Name("arkonIsBorn")
}

enum Launchpad: Equatable {
    static func == (lhs: Launchpad, rhs: Launchpad) -> Bool {
        func isEmpty(_ theThing: Launchpad) -> Bool {
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

typealias PendingGenome = (Int?, Genome)
struct PendingGenomes {

    var pendingGenomes = [PendingGenome]() { didSet {
        DebugPortal.shared.specimens[.cPendingGenomes]?.value = pendingGenomes.count
    }}

    mutating func fill(cArkons: Int) {
        DispatchQueue.global(qos: .background).sync {
            pendingGenomes =
                Array.init(repeating: (nil, Arkonery.aboriginalGenome), count: cArkons)
        }
    }

    mutating func pushBack(_ pendingGenome: PendingGenome) {
        DispatchQueue.global(qos: .background).sync { pendingGenomes.append(pendingGenome) }
    }

    mutating func popFront() -> PendingGenome? {
        return DispatchQueue.global(qos: .background).sync {
            if pendingGenomes.isEmpty { return nil }
            return pendingGenomes.removeFirst()
        }
    }
}

class Arkonery: NSObject {
    static var aboriginalGenome: Genome { return Assembler.makeRandomGenome(cGenes: 200) }
    static var shared: Arkonery!

    var cAttempted = 0 { didSet {
        DebugPortal.shared.specimens[.cAttempted]?.value = cAttempted
    }}

    var cBirthFailed = 0 { didSet {
        DebugPortal.shared.specimens[.cBirthFailed]?.value = cBirthFailed
    }}

    var cLivingArkons = 0 { didSet {
        DebugPortal.shared.specimens[.cLivingArkons]?.value = cLivingArkons
    }}

    var pendingGenomes = PendingGenomes()

    var arkonsPortal: SKSpriteNode
    let cropper: SKCropNode
//    let dispatchQueue = DispatchQueue(label: "carkonery")
    var launchpad = Launchpad.empty
    let netPortal: SKSpriteNode
    let notificationCanter = NotificationCenter.default
    var tickWorkItem: DispatchWorkItem!

    init(arkonsPortal: SKSpriteNode, netPortal: SKSpriteNode) {
        self.netPortal = netPortal

        self.arkonsPortal = arkonsPortal
        self.arkonsPortal.colorBlendFactor = 1.0
        self.cropper = SKCropNode()

        self.cropper.position = CGPoint(x: -Display.shared.scene!.frame.size.width / 4.0, y: 0)

        Display.shared.scene!.addChild(cropper)
        arkonsPortal.removeFromParent()
        self.cropper.addChild(self.arkonsPortal)

        self.arkonsPortal.size.height *= 2.0
        self.arkonsPortal.position = CGPoint.zero

        let height = Display.shared.scene!.frame.size.height * 0.99
        let width = Display.shared.scene!.frame.size.width / 2.0 * 0.99
        let maskNode = SKSpriteNode( color: .yellow, size: CGSize.make(width, height))

        maskNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.cropper.maskNode = maskNode

        self.cropper.zPosition = ArkonCentralLight.vArkonZPosition - 0.01

        arkonsPortal.speed = 0.1
    }

    private func getArkon(for sprite: SKNode) -> Arkon? {
        return (((sprite as? SKSpriteNode)?.userData?["Arkon"]) as? Arkon)
    }

    func makeArkon(parentFishNumber: Int?, parentGenome: Genome) -> Launchpad {
        let (newGenome, fNet_) = makeNet(parentGenome: parentGenome)

        guard let fNet = fNet_, !fNet.layers.isEmpty
            else { return .dead(parentFishNumber) }

        guard let arkon = Arkon(genome: newGenome, fNet: fNet, portal: arkonsPortal)
            else { return .dead(parentFishNumber) }

       return .alive(parentFishNumber, arkon)
    }

    private func makeNet(parentGenome: Genome) -> (Genome, FNet?) {
        let newGenome = parentGenome.copy()
        Mutator.shared.mutate(newGenome)

        let e = FDecoder.shared.decode(newGenome)
        return (newGenome, e as? FNet)
    }

    func spawn(parentID: Int?, parentGenome: Genome) {
        cAttempted += 1
        pendingGenomes.pushBack((parentID, parentGenome))
    }

    func spawnStarterPopulation(cArkons: Int) {
        cAttempted += cArkons
        pendingGenomes.fill(cArkons: cArkons)
    }

    func trackNotableArkon() {
        guard var tracker = ArkonTracker(arkonsPortal: arkonsPortal, netPortal: netPortal)
            else { return }

        guard let oldestLivingArkon = tracker.oldestLivingArkon
            else { return }

        if !oldestLivingArkon.isShowingNet {
            oldestLivingArkon.sprite.size *= 2.0
        }

        tracker.updateDebugPortal()
        tracker.updateNetPortal()
    }

}
