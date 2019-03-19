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
        return Assembler.makeRandomGenome(cGenes: Int.random(in: 10..<1000))
    }

    static var shared: ArkonFactory!

    var cAttempted = 0
    var cBirthFailed = 0
    var cGenerations = 0
    var cPending = 0
    var hiWaterCLiveArkons = 0
    var hiWaterGenomeLength = 0

    var cLiveArkons: Int { return World.shared.population.getCLiveArkons() }

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

    var histogramBuckets: [Int: Int]
    var histogramPortal: HistogramPortal
    var theOtherHistogramBuckets: [Int: Int]
    var theOtherHistogramPortal: HistogramPortal

    override init() {
        self.pendingArkons = Serializer<Arkon>(dispatchQueueLight)

        histogramBuckets = (0..<10).reduce([Int: Int]()) { (d, key) -> [Int: Int] in
            var dictionary = d
            dictionary[key] = 0
            return dictionary
        }

        let histogramName = "mutationTypeCountsHistogram"
        let barsName = "mutationTypesHistogramBars"
        histogramPortal = HistogramPortal(PortalServer.shared!.topLevelStatsPortal,
                                          histogramPortal: histogramName, barsName: barsName)

        HistogramPortal.postInit(histogramPortal)

        theOtherHistogramBuckets = (0..<10).reduce([Int: Int]()) { (d, key) -> [Int: Int] in
            var dictionary = d
            dictionary[key] = 0
            return dictionary
        }

        let theOtherHistogramName = "theOtherHistogram"
        let theOtherBarsName = "theOtherHistogramBars"
        theOtherHistogramPortal = HistogramPortal(
            PortalServer.shared!.topLevelStatsPortal,
            histogramPortal: theOtherHistogramName,
            barsName: theOtherBarsName
        )

        HistogramPortal.postInit(theOtherHistogramPortal)

        super.init()

        theOtherHistogramPortal.attachToColumns {
            [weak self] in Double(self?.theOtherHistogramBuckets[$0] ?? 0)
        }

        histogramPortal.attachToColumns {
            [weak self] in Double(self?.histogramBuckets[$0] ?? 0)
        }

        setupSubportal0()
        setupSubportal3()
    }

    func makeArkon(parentFishNumber: Int?, parentGenome: [GeneProtocol]) -> Arkon? {
        let (newGenome, fNet_) = makeNet(parentGenome: parentGenome)

        guard let fNet = fNet_, !fNet.layers.isEmpty else { return nil }

        guard let arkon = Arkon(
            parentFishNumber: parentFishNumber, genome: newGenome,
            fNet: fNet, portal: PortalServer.shared.arkonsPortal.get()
            ) else { return nil }

        return arkon
    }

    private func makeNet(parentGenome: [GeneProtocol]) -> ([GeneProtocol], FNet?) {
        let newGenome = Mutator.shared.mutate(parentGenome)

        let fNet = FDecoder.shared.decode(newGenome)
        return (newGenome, fNet)
    }

    func makeProtoArkon(parentFishNumber: Int?,
                        parentGenome parentGenome_: [GeneProtocol]?)
    {
        cAttempted += 1
        cPending += 1

        let darkOps = BlockOperation {
            defer { self.cPending -= 1 }

            let parentGenome = parentGenome_ ?? ArkonFactory.getAboriginalGenome()

            if let protoArkon = ArkonFactory.shared.makeArkon(
                parentFishNumber: parentFishNumber, parentGenome: parentGenome
                ) {
                self.pendingArkons.pushBack(protoArkon)

                // Just for debugging, so I can see who's doing what
                World.shared.population.getArkon(for: parentFishNumber)?.sprite.color = .yellow
            } else {
                self.cBirthFailed += 1
                guard let arkon = World.shared.population.getArkon(for: parentFishNumber) else { return }

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
}
