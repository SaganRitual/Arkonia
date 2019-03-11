import Foundation
import SpriteKit

struct DStat {
    let getter: () -> String
    let labelNode: SKLabelNode

    init(portal: SKSpriteNode, fontSize: CGFloat, getter: @escaping () -> String) {
        self.getter = getter
        self.labelNode = SKLabelNode(text: nil)

        self.labelNode.zPosition = ArkonCentralLight.vLabelZPosition
        self.labelNode.fontColor = .green
        self.labelNode.fontName = "Courier New"
        self.labelNode.fontSize = fontSize
        self.labelNode.numberOfLines = 3
        self.labelNode.position.y -= portal.size.height / 2

        portal.addChild(self.labelNode)
    }

    func tick() { labelNode.text = getter() }
}

class DStatsSubportal {
    static var recordGeneLength = 0

    var dstat: DStat!
    var histogram: DStatsHistogram?
    var sprite: SKSpriteNode!
    let statID: DStatsPortal.StatID
    var sources = [(DStatsPortal.StatID, () -> String)]()

    init(position: CGPoint, statID: DStatsPortal.StatID) {
        self.statID = statID
        self.sprite = SKSpriteNode(
            color: .black,
            size: DPortalServer.shared!.portals[3]!.frame.size * 2 / 3 * 0.99
        )

        self.sprite.colorBlendFactor = 1.0
        self.sprite.zPosition = ArkonCentralLight.vSubportalZPosition
        self.sprite.position = position

        self.sources = [
            (.gameAge, dsGameAge), (.liveLabel, {""}), (.seniorLabel, {""}),
            (.foodValue, dsMiscellaney), (.cLiveGenes, dsLiveGenes), (.seniorAge, Arkon.getSeniorAgeStats),
            (.cArkons, dsLiveArkons), (.cSpawnLabel, dsSpawn), (.seniorHealth, Arkon.getSeniorHealthStats)
        ]

        self.dstat = DStat(
            portal: self.sprite, fontSize: 25.0,
            getter: sources.filter { s in s.0 == statID }[0].1
        )

        switch statID {
        case .gameAge:
            guard let labelNode = (self.sprite.children[0] as? SKLabelNode) else {
                preconditionFailure()
            }

            labelNode.fontSize = 50.0
            labelNode.position.y += (self.sprite.frame.size.height - labelNode.frame.size.height) / 4

        case .liveLabel:
            histogram = MutatorStatsHistogram(
                parentPortal: self.sprite, cColumns: Mutator.MutationType.allCases.count
            )

        case .seniorLabel:
            histogram = SegmentMutationStatsHistogram(
                parentPortal: self.sprite, cColumns: Mutator.MutationType.allCases.count
            )

        default: break
        }

        DPortalServer.shared!.portals[3]!.addChild(self.sprite)
    }

    func tick() { dstat.tick() }
}

extension DStatsSubportal {
    func dsGameAge() -> String {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute, .second]
        f.allowsFractionalUnits = true
        f.unitsStyle = .positional
        f.zeroFormattingBehavior = .pad
        return f.string(from: Display.shared!.gameAge) ?? "0.0"
    }

    func dsHistogram() -> String {
        return ""
    }

    func dsLiveLabel() -> String { return "Live" }
    func dsSeniorLabel() -> String { return "Senior" }

    func dsMiscellaney() -> String {
        return String(
            format: "Food value: %.1f%%\nGenerations: %d",
                Display.shared.entropyFactor * 100, ArkonFactory.shared.cGenerations
        )
    }

    func dsSpawn() -> String {
        let all = ArkonFactory.shared.cAttempted
        let fail = ArkonFactory.shared.cBirthFailed
        let succeed = all - fail
        let sr = (all == 0) ? 0 : Double(succeed) / Double(all)
        let successRate = String(format: "%.2f%", sr * 100.0)
        return String(
            "Spawns: \(all)\n" +
            "Successes: \(succeed)\n" +
            "Failures: \(fail)\n" +
            "SuccessRate: \(successRate)"
        )
    }

    func dsLiveGenes() -> String {
        let arkons = World.shared.arkonsPortal.children.compactMap { ($0 as? SKSpriteNode)?.arkon }
        let alternateCount = arkons.reduce(0) { $0 + $1.genome.count }
        if alternateCount > Gene.highWaterMark { Gene.highWaterMark = alternateCount }

        let averageGenomeLength = ArkonFactory.shared.cLivingArkons == 0 ? 0 :
            (Double(alternateCount) / Double(ArkonFactory.shared.cLivingArkons))

        let formattedAverage = String(format: "%.2f", averageGenomeLength)

        let sorted = arkons.sorted { $0.genome.count < $1.genome.count }
        let medianGeneLength = sorted.isEmpty ? 0 : sorted[sorted.count / 2].genome.count
        let longestLiveGene = sorted.last?.genome.count ?? 0

        if longestLiveGene > DStatsSubportal.recordGeneLength {
            DStatsSubportal.recordGeneLength = longestLiveGene
        }

        return "Live genes: \(alternateCount)\n" +
                "High water: \(Gene.highWaterMark)\n" +
                "Average: \(formattedAverage)\n" +
                "Median: \(medianGeneLength)\n" +
                "Longest: \(longestLiveGene)\n" +
                "Record: \(DStatsSubportal.recordGeneLength)"
    }

    func dsLiveArkons() -> String {
        return "Live arkons: \(ArkonFactory.shared.cLivingArkons)\n" +
                "High water: \(ArkonFactory.shared.highWaterMark)\n" +
                "Pending fab: \(ArkonFactory.shared.cPending)\n" +
                "Pending launch: \(ArkonFactory.shared.pendingArkons.count)"
    }
}

struct DStatsPortal {
    static var shared: DStatsPortal!

    weak var sprite: SKSpriteNode!
    var subportals = [SubportalID: DStatsSubportal]()

    let subportalToDStat: [SubportalID: StatID] = [
        SubportalID.gameAge: StatID.gameAge, SubportalID.liveLabel: StatID.liveLabel,
        SubportalID.seniorLabel: StatID.seniorLabel, SubportalID.miscellaney: StatID.foodValue,
        SubportalID.seniorAge: StatID.seniorAge,
        SubportalID.liveGenes: StatID.cLiveGenes, SubportalID.cLiveArkon: StatID.cArkons,
        SubportalID.cSpawn: StatID.cSpawnLabel, SubportalID.seniorHealth: StatID.seniorHealth
    ]

    init(_ cSubportal: Int) {
        self.sprite = Display.shared.getPortal(quadrant: 3)
        self.sprite.color = Display.shared.scene!.backgroundColor
        self.sprite.colorBlendFactor = 1.0
        self.sprite.zPosition = ArkonCentralLight.vSubportalZPosition

        let positions: [(CGFloat, CGFloat)] = [
            (-1, 1), (0, 1), (1, 1), (-1, 0), (0, 0), (1, 0), (-1, -1), (0, -1), (1, -1)
        ]

        SubportalID.allCases.enumerated().forEach { ss, id in
            let size = Display.shared.scene!.frame.size / 27
            let position = CGPoint(
                x: size.width * 9 * CGFloat(positions[ss].0),
                y: size.height * 9 * CGFloat(positions[ss].1)
            )

            let ds = DStatsSubportal(position: position, statID: subportalToDStat[id]!)
            subportals[id] = ds
        }
    }

    func tick() { subportals.forEach { $0.1.tick() } }
}

extension DStatsPortal {

    enum SubportalID: CaseIterable, Hashable {
        case gameAge, liveLabel, seniorLabel
        case miscellaney, liveGenes, seniorAge
        case cSpawn, cLiveArkon, seniorHealth
    }

    enum StatID {
        case gameAge, liveLabel, seniorLabel
        case miscellaney, liveGenesLabel, seniorAgeLabel
        case cSpawnLabel, cLiveArkonLabel, seniorHealthLabel

        case foodValue, cGenerations
        case cLiveGenes, averageGenes, highWaterGenes
        case cArkons, backlog, highWaterArkons

        case seniorAge, currentAverageAge, recordAge
        case seniorHealth, offspring, highWaterOffspring
    }
}
