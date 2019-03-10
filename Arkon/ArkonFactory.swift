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

class Serializer<T> {
    private var array = [T]()
    private let queue: DispatchQueue

    var isEmpty: Bool { return array.isEmpty }

    init(_ queue: DispatchQueue) { self.queue = queue }

    func pushBack(_ item: T) { queue.sync { array.append(item) } }

    func popFront() -> T? {
        return queue.sync { if array.isEmpty { return nil }; return array.removeFirst() }
    }
}

class ArkonFactory: NSObject {
    static var aboriginalGenome: [Gene] { return Assembler.makeRandomGenome(cGenes: 200) }
    static var shared: ArkonFactory!

    var cAttempted = 0
    var cBirthFailed = 0
    var cGenerations = 0
    var cLivingArkons = 0 { willSet { if newValue > highWaterMark { highWaterMark = newValue } } }
    var highWaterMark = 0
    var cPending = 0

    var arkonsPortal: SKSpriteNode
    let cropper: SKCropNode
    let dispatchQueueLight = DispatchQueue(label: "light.arkonia")
    var launchpad = Launchpad.empty
    let netPortal: SKSpriteNode
    let notificationCanter = NotificationCenter.default
    var pendingArkons: Serializer<Arkon>
    var tickWorkItem: DispatchWorkItem!

    static let arkonMakerQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "arkon.dark.queue"
        q.qualityOfService = .background
        q.maxConcurrentOperationCount = 1
        return q
    }()

    init(arkonsPortal: SKSpriteNode, netPortal: SKSpriteNode) {
        self.pendingArkons = Serializer<Arkon>(dispatchQueueLight)

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

    private func getArkon(for sprite: SKNode) -> Arkon? { return (sprite as? SKSpriteNode)?.arkon }

    func getArkon(for fishNumber: Int?) -> Arkon? {
        guard let fn = fishNumber else { return nil }
        return (arkonsPortal.children.first(where: {
            guard let sprite = ($0 as? SKSpriteNode) else { return false }
            return (sprite.arkon?.fishNumber ?? -42) == fn
        }) as? SKSpriteNode)?.arkon
    }

    func makeArkon(parentFishNumber: Int?, parentGenome: [Gene]) -> Arkon? {
        let (newGenome, fNet_) = makeNet(parentGenome: parentGenome)

        guard let fNet = fNet_, !fNet.layers.isEmpty else { return nil }

        guard let arkon = Arkon(parentFishNumber: parentFishNumber,
                                genome: newGenome, fNet: fNet, portal: arkonsPortal)
            else { return nil }

       return arkon
    }

    private func makeNet(parentGenome: [Gene]) -> ([Gene], FNet?) {
        let newGenome = Mutator.shared.mutate(parentGenome)

        let fNet = FDecoder.shared.decode(newGenome)
        return (newGenome, fNet)
    }

    func makeProtoArkon(parentFishNumber parentFishNumber_: Int?,
                        parentGenome parentGenome_: [Gene]?)
    {
        cAttempted += 1
        cPending += 1

        let darkOps = BlockOperation {
            defer { self.cPending -= 1 }

            let parentGenome = parentGenome_ ?? ArkonFactory.aboriginalGenome
            let parentFishNumber = parentFishNumber_ ?? -42

            if let protoArkon = ArkonFactory.shared.makeArkon(
                parentFishNumber: parentFishNumber, parentGenome: parentGenome
                ) {
                self.pendingArkons.pushBack(protoArkon)

                // Just for debugging, so I can see who's doing what
                self.getArkon(for: parentFishNumber)?.sprite.color = .yellow
            } else {
                self.cBirthFailed += 1
                guard let arkon = self.getArkon(for: parentFishNumber) else { return }
                arkon.sprite.color = .blue
                arkon.sprite.run(arkon.tickAction)
            }
        }

        darkOps.queuePriority = .veryLow
        ArkonFactory.arkonMakerQueue.addOperation(darkOps)
    }

    func spawn(parentFishNumber: Int?, parentGenome: [Gene]) {
        makeProtoArkon(parentFishNumber: parentFishNumber, parentGenome: parentGenome)
   }

    func spawnStarterPopulation(cArkons: Int) {
        (0..<cArkons).forEach { _ in makeProtoArkon(parentFishNumber: nil, parentGenome: nil) }
    }

    func trackNotableArkon() {
        guard var tracker = ArkonTracker(arkonsPortal: arkonsPortal, netPortal: netPortal)
            else { return }

        guard let oldestLivingArkon = tracker.oldestLivingArkon
            else { return }

        Arkon.currentAgeOfOldestArkon = oldestLivingArkon.myAge

        if !oldestLivingArkon.isShowingNet {
            oldestLivingArkon.isOldestArkon = true
            oldestLivingArkon.sprite.size *= 2.0
        }

        tracker.updateNetPortal()
    }

}
