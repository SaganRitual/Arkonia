import SpriteKit

struct Fishday {
    private static var TheFishNumber = 0

    let birthday: TimeInterval
    let cNeurons: Int
    let fishNumber: Int
    let name: ArkonName

    // All this needs to happen on a serial queue. The Census serial
    // queue seems like the most sensible one, given that it's census-related
    init(currentTime: Int, cNeurons: Int) {
        self.cNeurons = cNeurons
        self.fishNumber = Fishday.getNextFishNumber()
        self.name = ArkonName.makeName()
        self.birthday = TimeInterval(currentTime)
    }

    private static func getNextFishNumber() -> Int {
        defer { Fishday.TheFishNumber += 1 }
        return Fishday.TheFishNumber
    }
}

class Census {
    static var shared = Census()

    let censusAgent = CensusAgent()
    let lineChartData = LineChartData(6)

    private(set) var allBirths = 0
    private(set) var cLiveNeurons = 0
    private(set) var highwaterAge: TimeInterval = 0
    private(set) var highwaterPopulation = 0
    private(set) var highwaterFoodHitrate = 0.0
    private(set) var highwaterCOffspring = 0.0
    var populated = false

    // Markers for said arkons, not the arkons themselves
    var oldestLivingMarker, aimestLivingMarker, busiestLivingMarker: SKSpriteNode?
    var markers = [SKSpriteNode]()

    var tickTimer: Timer!

    static let dispatchQueue = DispatchQueue(
        label: "ak.census.q",
        target: DispatchQueue.global()
    )

    init() {
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Census.dispatchQueue.async { self.updateReports() }
        }
    }

    func reSeedWorld() { populated = false }

    func setupMarkers() {
        oldestLivingMarker = SpriteFactory.shared.markersPool.getDrone()
        aimestLivingMarker = SpriteFactory.shared.markersPool.getDrone()
        busiestLivingMarker = SpriteFactory.shared.markersPool.getDrone()

        markers.append(contentsOf: [
            oldestLivingMarker!, aimestLivingMarker!, busiestLivingMarker!
        ])

        let colors: [SKColor] = [.yellow, .orange, .green]

        zip(0..., markers).forEach { ss, marker in
            marker.color = colors[ss]
            marker.colorBlendFactor = 1
            marker.zPosition = 10
            marker.zRotation = -CGFloat.tau * CGFloat(ss) / CGFloat(markers.count)
            marker.setScale(Arkonia.markerScaleFactor)
        }
    }
}

extension Census {
    static func getAge(of arkon: Stepper, at currentTime: Int) -> TimeInterval {
        return TimeInterval(currentTime) - arkon.fishday.birthday
    }
}

extension Census {
    func updateReports(_ worldClock: Int) {
        censusAgent.compress(TimeInterval(worldClock), self.allBirths)

        markExemplars()

        highwaterAge = TimeInterval(max(censusAgent.stats.maxAge, highwaterAge))
        highwaterCOffspring = TimeInterval(max(censusAgent.stats.maxCOffspring, highwaterCOffspring))
        highwaterFoodHitrate = max(censusAgent.stats.maxFoodHitRate, highwaterFoodHitrate)
        highwaterPopulation = max(censusAgent.stats.currentPopulation, highwaterPopulation)

        lineChartData.update([
            censusAgent.stats.averageAge, censusAgent.stats.maxAge,
            censusAgent.stats.medAge, 0, 0, Double(highwaterAge)
        ])
    }
}

private extension Census {
    func markExemplars() {
        zip(
            [censusAgent.stats.oldestArkon, censusAgent.stats.bestAimArkon, censusAgent.stats.busiestArkon],
            [oldestLivingMarker, aimestLivingMarker, busiestLivingMarker]
        ).forEach {
            (a, m) in
            guard let arkon = a, let marker = m else { return }
            updateMarker(marker, arkon.thorax)
        }
    }

    func updateMarker(_ marker: SKSpriteNode, _ markCandidate: SKSpriteNode) {
        if marker.parent != nil {
            marker.alpha = 0
            marker.removeFromParent()
        }

        markCandidate.addChild(marker)

        marker.alpha = 1
    }
}

extension Census {
    func registerBirth(_ myNetStructure: NetStructure, _ myParent: Stepper?) -> Int {
        myParent?.censusData.increment(.offspring)
        self.allBirths += 1

        return myNetStructure.cNeurons
    }
}
