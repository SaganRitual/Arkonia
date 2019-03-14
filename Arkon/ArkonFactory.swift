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

    var count: Int { return array.count }
    var isEmpty: Bool { return array.isEmpty }

    init(_ queue: DispatchQueue) { self.queue = queue }

    func pushBack(_ item: T) { queue.sync { array.append(item) } }

    func popFront() -> T? {
        return queue.sync { if array.isEmpty { return nil }; return array.removeFirst() }
    }
}

class ArkonFactory: NSObject {
    static func getAboriginalGenome() -> [GeneProtocol] {
        return Assembler.makeRandomGenome(cGenes: 200)
    }

    static var shared: ArkonFactory!

    var cAttempted = 0
    var cBirthFailed = 0
    var cGenerations = 0
    var cLiveArkons = 0 { willSet { if newValue > hiWaterCLiveArkons { hiWaterCLiveArkons = newValue } } }
    var cPending = 0
    var hiWaterCLiveArkons = 0
    var hiWaterGenomeLength = 0

    var longestLivingGenomeLength: Int {
        let geneCounts = getGeneCounts()
        let longest = geneCounts.last ?? 0
        if longest > hiWaterGenomeLength { hiWaterGenomeLength = longest }
        return longest
    }

    var medianLivingGenomeLength: Int {
        let geneCounts = getGeneCounts()
        return geneCounts.isEmpty ? 0 : geneCounts[geneCounts.count / 2]
    }

    let dispatchQueueLight = DispatchQueue(label: "light.arkonia")
    var launchpad = Launchpad.empty
    var pendingArkons: Serializer<Arkon>
    var tickWorkItem: DispatchWorkItem!

    static let arkonMakerQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "arkon.dark.queue"
        q.qualityOfService = .background
        q.maxConcurrentOperationCount = 1
        return q
    }()

    override init() {
        self.pendingArkons = Serializer<Arkon>(dispatchQueueLight)
        super.init()

        setupSubportal0()
        setupSubportal3()
   }

    private func getArkon(for sprite: SKNode) -> Arkon? { return (sprite as? SKSpriteNode)?.arkon }

    func getArkon(for fishNumber: Int?) -> Arkon? {
        guard let fn = fishNumber else { return nil }
        return (PortalServer.shared.arkonsPortal.children.first(where: {
            guard let sprite = ($0 as? SKSpriteNode) else { return false }
            return (sprite.arkon?.fishNumber ?? -42) == fn
        }) as? SKSpriteNode)?.arkon
    }

    func getGeneCounts() -> [Int] {
        return PortalServer.shared.arkonsPortal.children.compactMap { node in
            guard let sprite = node as? SKSpriteNode else { return nil }
            guard let arkon = sprite.arkon else { return nil }
            return arkon.genome.count
        }.sorted(by: <)
    }

    func makeArkon(parentFishNumber: Int?, parentGenome: [GeneProtocol]) -> Arkon? {
        let (newGenome, fNet_) = makeNet(parentGenome: parentGenome)

        guard let fNet = fNet_, !fNet.layers.isEmpty else { return nil }

        guard let arkon = Arkon(
            parentFishNumber: parentFishNumber, genome: newGenome,
            fNet: fNet, portal: PortalServer.shared.arkonsPortal
            ) else { return nil }

        return arkon
    }

    private func makeNet(parentGenome: [GeneProtocol]) -> ([GeneProtocol], FNet?) {
        let newGenome = Mutator.shared.mutate(parentGenome)

        let fNet = FDecoder.shared.decode(newGenome)
        return (newGenome, fNet)
    }

    func makeProtoArkon(parentFishNumber parentFishNumber_: Int?,
                        parentGenome parentGenome_: [GeneProtocol]?)
    {
        cAttempted += 1
        cPending += 1

        let darkOps = BlockOperation {
            defer { self.cPending -= 1 }

            let parentGenome = parentGenome_ ?? ArkonFactory.getAboriginalGenome()
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
                arkon.sprite.run(SKAction.sequence([
                    arkon.tickAction,
                    SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 0.25)
                ]))
            }
        }

        darkOps.queuePriority = .veryLow
        ArkonFactory.arkonMakerQueue.addOperation(darkOps)
    }

    func setupSubportal0() {
        PortalServer.shared.generalStatsPortals.setUpdater(subportal: 0, field: 3) { [weak self] in
            return String(format: "Generations: %d", self?.cGenerations ?? 0)
        }
    }

    func setupSubportal3() {
        PortalServer.shared.generalStatsPortals.setUpdater(subportal: 3, field: 0) { [weak self] in
            return String(format: "Spawns: %d", self?.cAttempted ?? 0)
        }

        PortalServer.shared.generalStatsPortals.setUpdater(subportal: 3, field: 1) { [weak self] in
            guard let myself = self else { return "" }
            let cSuccesses = myself.cAttempted - myself.cBirthFailed
            return String(format: "Success: %d", cSuccesses)
        }

        PortalServer.shared.generalStatsPortals.setUpdater(subportal: 3, field: 2) { [weak self] in
            return String(format: "Failure: %d", self?.cBirthFailed ?? 0)
        }

        PortalServer.shared.generalStatsPortals.setUpdater(subportal: 3, field: 3) { [weak self] in
            guard let myself = self else { return "" }
            let cSuccesses = myself.cAttempted - myself.cBirthFailed
            let rate = 100.0 * Double(cSuccesses) / Double(myself.cAttempted)
            return String(format: "Success rate: %.1f%%", rate)
        }
    }

    func spawn(parentFishNumber: Int?, parentGenome: [GeneProtocol]) {
        makeProtoArkon(parentFishNumber: parentFishNumber, parentGenome: parentGenome)
   }

    func spawnStarterPopulation(cArkons: Int) {
        (0..<cArkons).forEach { _ in makeProtoArkon(parentFishNumber: nil, parentGenome: nil) }
    }

    func trackNotableArkon() {
        guard var tracker = ArkonTracker(
            arkonsPortal: PortalServer.shared!.arkonsPortal, netPortal: PortalServer.shared!.netPortal
        ) else { return }

        guard let oldestLivingArkon = tracker.oldestLivingArkon
            else { return }

        Arkon.currentAgeOfOldestArkon = oldestLivingArkon.myAge

        if !oldestLivingArkon.isShowingNet {
            oldestLivingArkon.isOldestArkon = true
            oldestLivingArkon.sprite.size *= 2.0
            Arkon.currentCOffspring = oldestLivingArkon.cOffspring
        }

        tracker.updateNetPortal()
    }

}
