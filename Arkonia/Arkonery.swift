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

class Arkonery {
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

    var pendingGenomes = [(Int?, Genome)]() { didSet {
        DebugPortal.shared.specimens[.cPendingGenomes]?.value = pendingGenomes.count
    }}

    var arkonsPortal: SKSpriteNode
    let cropper: SKCropNode
    let dispatchQueue = DispatchQueue(label: "carkonery")
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

    func postInit() {
        self.tickWorkItem = DispatchWorkItem { [unowned self] in self.tick() }
    }

    private func getArkon(for sprite: SKNode) -> Arkon? {
        return (((sprite as? SKSpriteNode)?.userData?["Arkon"]) as? Arkon)
    }

    private func makeArkon(parentFishNumber: Int?, parentGenome: Genome) -> Launchpad {
        defer { cAttempted += 1 }

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

    static func reviveSpawner(fishNumber: Int) {
        let n = Foundation.Notification.Name.arkonIsBorn
        NotificationCenter.default.post(
            name: n, object: self, userInfo: ["parentFishNumber": fishNumber]
        )
    }

    private func scheduleTick() { dispatchQueue.async(execute: tickWorkItem) }

    private var oldestArkonAge: TimeInterval = 0 { didSet {
        DebugPortal.shared.specimens[.recordAge]?.value = Int(oldestArkonAge)
    }}

    func setDisplayNet() {
        func getAge(_ node: SKNode) -> TimeInterval {
            return self.getArkon(for: node)?.myAge ?? 0
        }

        func getArkon(_ dictionary: NSMutableDictionary?) -> Arkon? {
            return dictionary?["Arkon"] as? Arkon
        }

        func getKNet(_ arkon: Arkon) -> KNet? {
            return arkon.signalDriver.kNet
        }

        if arkonsPortal.children.isEmpty { return }

        let spriteOfOldestLivingArkon = arkonsPortal.children.max { lhs, rhs in
            return getAge(lhs) < getAge(rhs)
        }

        guard let sprite = spriteOfOldestLivingArkon else { return }
        guard let arkon = getArkon(sprite.userData) else { return }
        guard arkon.birthday > 0 && arkon.myAge > (oldestArkonAge + 0.016) else { return }

        oldestArkonAge = arkon.myAge

        guard let kNet = getKNet(arkon) else { return }
        Display.shared.display(kNet, portal: netPortal)
    }

    func spawn(parentID: Int?, parentGenome: Genome) {
        dispatchQueue.async { [unowned self] in
            let needTick = self.pendingGenomes.isEmpty
            self.pendingGenomes.append((parentID, parentGenome))
            if needTick { self.dispatchQueue.async(execute: self.tickWorkItem) }
        }
    }

    func tick() {
        defer { if !pendingGenomes.isEmpty { scheduleTick() } }

        if launchpad != .empty { return }

        let (parentFishNumber, parentGenome) = pendingGenomes.removeFirst()
        let state = makeArkon(parentFishNumber: parentFishNumber, parentGenome: parentGenome)

        cAttempted += 1

        switch state {
        case .alive:
            cLivingArkons += 1
            launchpad = state

        case .dead(.none):
            cBirthFailed += 1

        case .dead(.some(let parentFishNumber)):
            cBirthFailed += 1
            Arkonery.reviveSpawner(fishNumber: parentFishNumber)

        // makeArkon() shouldn't return this; it's n/a to arkon state
        case .empty: preconditionFailure()
        }
    }

}
