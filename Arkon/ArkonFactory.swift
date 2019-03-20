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

struct BasicBarChartSource: BarChartSource {
    let source: LogHistogram

    init(_ source: LogHistogram) { self.source = source }

    //swiftlint:disable large_tuple
    func getCountsCompressed() -> (Double, [Int], Int) {
        return source.getCountsCompressed(to: 10)
    }
    //swiftlint:enable large_tuple

    func getCountsTruncated() -> ([Int], Int) {
        return source.getCountsTruncated(to: 10)
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

    let logHistogram = LogHistogram(sampleResolution: 1)
    var barChart = SetOnce<BarChart>()
    var barChartSource: BasicBarChartSource

    let auxLogHistogram = LogHistogram(sampleResolution: 1)
    var auxBarChart = SetOnce<BarChart>()
    var auxBarChartSource: BasicBarChartSource

    override init() {
        self.pendingArkons = Serializer<Arkon>(dispatchQueueLight)

        barChartSource = BasicBarChartSource(logHistogram)
        auxBarChartSource = BasicBarChartSource(auxLogHistogram)

        super.init()

        let portal = PortalServer.shared.topLevelStatsPortal

        barChart.set(ArkonFactory.makeBarChart(
            namePrefix: "",
            parentNode: portal,
            dataSource: barChartSource
        ))

        self.barChart.get().barChartLabel.text = "Lifespan"

        auxBarChart.set(ArkonFactory.makeBarChart(
            namePrefix: "aux_",
            parentNode: portal,
            dataSource: auxBarChartSource
        ))

        self.auxBarChart.get().barChartLabel.text = "Genome"

        setupSubportal0()
        setupSubportal3()
    }

    static func makeBarChart(
        namePrefix: String,
        parentNode: SKSpriteNode,
        dataSource: BarChartSource)
        -> BarChart
    {
        let backgroundName = namePrefix + "bar_chart_background"
        guard let chartNode = parentNode.childNode(withName: backgroundName) as? SKSpriteNode
            else { preconditionFailure() }

        return BarChart(chartNode: chartNode, namePrefix: namePrefix, datasource: dataSource)
    }

    func makeArkon(parentFishNumber: Int?, parentGenome: [GeneProtocol]) -> Arkon? {
        let newGenome = Mutator.shared.mutate(parentGenome)

        guard let fNet = FDecoder.shared.decode(newGenome), !fNet.layers.isEmpty
            else { return nil }

        guard let arkon = Arkon(
            parentFishNumber: parentFishNumber,
            genome: newGenome,
            fNet: fNet,
            portal: PortalServer.shared.arkonsPortal.get()
        ) else { return nil }

        return arkon
    }

    func makeProtoArkon(parentFishNumber: Int?, parentGenome parentGenome_: [GeneProtocol]?) {
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
