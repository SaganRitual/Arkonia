import Foundation
import SpriteKit

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
        return Assembler.makeRandomGenome(cGenes: Int.random(in: 200..<500))
    }

    static var shared: ArkonFactory!
    static let scale: CGFloat = 0.25

    var cAttempted = 0
    var cBirthFailed = 0
    var cGenerations = 0
    var cPending = 0
    var hiWaterCLiveArkons = 0
    var hiWaterGenomeLength = 0

    var cLiveArkons: Int { return World.shared.population.getCLiveArkons() }

    var tickWorkItem: DispatchWorkItem!

    static let karambaSerializerQueue = DispatchQueue(label: "light.karamba", qos: .background)
    static let karambaStimulusQueue =
        DispatchQueue(label: "dark.karamba", qos: .background, attributes: .concurrent)

    let logHistogram = LogHistogram(sampleResolution: 1)
    var barChart: BarChart!
    var barChartSource: BasicBarChartSource

    let auxLogHistogram = LogHistogram(sampleResolution: 1)
    var auxBarChart: BarChart!
    var auxBarChartSource: BasicBarChartSource

    override init() {
        barChartSource = BasicBarChartSource(logHistogram)
        auxBarChartSource = BasicBarChartSource(auxLogHistogram)

        super.init()

        let portal = PortalServer.shared.topLevelStatsPortal

        barChart = ArkonFactory.makeBarChart(
            namePrefix: "",
            parentNode: portal,
            dataSource: barChartSource
        )

        self.barChart.barChartLabel.text = "Lifespan"

        auxBarChart = ArkonFactory.makeBarChart(
            namePrefix: "aux_",
            parentNode: portal,
            dataSource: auxBarChartSource
        )

        self.auxBarChart.barChartLabel.text = "Genome"

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
            portal: PortalServer.shared.arkonsPortal
        ) else { return nil }

        return arkon
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
}
