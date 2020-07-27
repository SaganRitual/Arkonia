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
    @Published var brainy = 0
    @Published var cLiveNeurons = 0
    @Published var cAverageNeurons = 0.0
    @Published var cOffspring = 0.0
    @Published var foodHitrate = 0.0
    @Published var population = 0
    @Published var roomy = 0

    var coreAge: TimeInterval = 0
    var coreAllBirths = 0
    var coreBrainy = 0
    var coreCLiveNeurons = 0
    var coreCAverageNeurons = 0.0
    var coreCOffspring = 0.0
    var coreFoodHitrate = 0.0
    var corePopulation = 0
    var coreRoomy = Int.max

    // swiftlint:disable function_parameter_count
    // Function Parameter Count Violation: Function should have 5 parameters
    // or less: it currently has 6
    func update(
        _ age: TimeInterval, _ allBirths: Int, _ cLiveNeurons: Int,
        _ cOffspring: Double, _ foodHitrate: Double, _ population: Int,
        _ cAverageNeurons: Double, _ cBrainy: Int, _ cRoomy: Int
    ) {
        Debug.log(level: 222) {
            "highwater \(cBrainy) \(cRoomy)"
        }
        DispatchQueue.main.async {
            self.age = age
            self.allBirths = allBirths
            self.cLiveNeurons = cLiveNeurons
            self.cOffspring = cOffspring
            self.foodHitrate = foodHitrate
            self.population = population
            self.cAverageNeurons = cAverageNeurons
            self.brainy = cBrainy
            self.roomy = cRoomy
        }
    }
    // swiftlint:enable function_parameter_count
}

class Census {
    static var shared = Census()

    let censusAgent = CensusAgent()
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
        seedWorld()
        updateReports()
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

private extension Census {
    func updateReports() {
        Clock.dispatchQueue.asyncAfter(deadline: .now() + 1) {
            let wc = Int(Clock.shared.worldClock)
            self.updateReports_B(wc)
        }
    }

    func updateReports_B(_ worldClock: Int) {
        Census.dispatchQueue.async {
            self.updateReports_C(worldClock)

            self.highwater.update(
                self.highwater.coreAge, self.highwater.coreAllBirths,
                self.highwater.coreCLiveNeurons, self.highwater.coreCOffspring,
                self.highwater.coreFoodHitrate, self.highwater.corePopulation,
                self.highwater.coreCAverageNeurons, self.highwater.coreBrainy,
                self.highwater.coreRoomy
            )
        }
    }

    func updateReports_C(_ worldClock: Int) {
        censusAgent.compress(TimeInterval(worldClock), self.highwater.coreAllBirths)

        self.highwater.coreAge = TimeInterval(max(censusAgent.stats.maxAge, self.highwater.coreAge))
        self.highwater.coreBrainy = max(censusAgent.stats.cBrainy, self.highwater.coreBrainy)
        self.highwater.coreCLiveNeurons = max(censusAgent.stats.cNeurons, self.highwater.cLiveNeurons)
        self.highwater.coreCOffspring = TimeInterval(max(censusAgent.stats.maxCOffspring, self.highwater.coreCOffspring))
        self.highwater.coreFoodHitrate = max(censusAgent.stats.maxFoodHitRate, self.highwater.coreFoodHitrate)
        self.highwater.corePopulation = max(censusAgent.stats.currentPopulation, self.highwater.corePopulation)
        self.highwater.coreCAverageNeurons = max(censusAgent.stats.cAverageNeurons, self.highwater.coreCAverageNeurons)

        if censusAgent.stats.cRoomy > 0 {
            self.highwater.coreRoomy = min(censusAgent.stats.cRoomy, self.highwater.coreRoomy)
        }

        markExemplars()
        updateReports()
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
        SceneDispatch.shared.schedule("updateMarker") {
            if marker.parent != nil {
                marker.alpha = 0
                marker.removeFromParent()
            }

            markCandidate.addChild(marker)

            marker.alpha = 1
        }
    }
}
