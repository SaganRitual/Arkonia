import SpriteKit
import SwiftUI

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

class CensusHighwater: ObservableObject {
    @Published var age: TimeInterval = 0
    @Published var allBirths = 0
    @Published var cLiveNeurons = 0
    @Published var cOffspring = 0.0
    @Published var foodHitrate = 0.0
    @Published var population = 0

    var coreAge: TimeInterval = 0
    var coreAllBirths = 0
    var coreCLiveNeurons = 0
    var coreCOffspring = 0.0
    var coreFoodHitrate = 0.0
    var corePopulation = 0

    func update() {
        DispatchQueue.main.async {
            self.age = self.coreAge
            self.allBirths = self.coreAllBirths
            self.cLiveNeurons = self.coreCLiveNeurons
            self.cOffspring = self.coreCOffspring
            self.foodHitrate = self.coreFoodHitrate
            self.population = self.corePopulation
        }
    }
}

class Census {
    static var shared = Census()

    let censusAgent = CensusAgent()
    let lineChartData = LineChartData(6)
    var highwater = CensusHighwater()

    var populated = false

    // Markers for said arkons, not the arkons themselves
    var oldestLivingMarker, aimestLivingMarker, busiestLivingMarker: SKSpriteNode?
    var markers = [SKSpriteNode]()

    var tickTimer: Timer!

    static let dispatchQueue = DispatchQueue(
        label: "ak.census.q",
        target: DispatchQueue.global()
    )

    func start() {
        setupMarkers()

        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async(execute: self.highwater.update)
            Census.dispatchQueue.async { self.updateReports() }
        }
    }

    func reSeedWorld() { populated = false }

    func setupMarkers() {
        let atlas = SKTextureAtlas(named: "Backgrounds")
        let texture = atlas.textureNamed("marker")

        oldestLivingMarker = SKSpriteNode(texture: texture)
        busiestLivingMarker = SKSpriteNode(texture: texture)
        aimestLivingMarker = SKSpriteNode(texture: texture)

        markers.append(contentsOf: [
            oldestLivingMarker!, busiestLivingMarker!, aimestLivingMarker!
        ])

        let colors: [SKColor] = [.yellow, .green, .orange]

        zip(0..., markers).forEach { ss, marker in
            marker.color = colors[ss]
            marker.colorBlendFactor = 1
            marker.zPosition = 10
            marker.setScale(Arkonia.markerScaleFactor / (CGFloat(ss) + 1.25 - CGFloat(ss) * 0.45))
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
        censusAgent.compress(TimeInterval(worldClock), self.highwater.coreAllBirths)

        markExemplars()

        self.highwater.coreAge = TimeInterval(max(censusAgent.stats.maxAge, self.highwater.coreAge))
        self.highwater.coreCOffspring = TimeInterval(max(censusAgent.stats.maxCOffspring, self.highwater.coreCOffspring))
        self.highwater.coreFoodHitrate = max(censusAgent.stats.maxFoodHitRate, self.highwater.coreFoodHitrate)
        self.highwater.corePopulation = max(censusAgent.stats.currentPopulation, self.highwater.corePopulation)

        lineChartData.update([
            censusAgent.stats.averageAge, censusAgent.stats.maxAge,
            censusAgent.stats.medAge, 0, 0, Double(self.highwater.coreAge)
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
        self.highwater.coreAllBirths += 1

        return myNetStructure.cNeurons
    }
}
