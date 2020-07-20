import SpriteKit

struct Fishday {
    private static var TheFishNumber = 0

    let birthday: TimeInterval
    let cNeurons: Int
    let fishNumber: Int
    let name: ArkonName

    // All this needs to happen on a serial queue. The Census serial
    // queue seems like the most sensible one, given that it's census-related
    init(cNeurons: Int) {
        self.cNeurons = cNeurons
        self.fishNumber = Fishday.getNextFishNumber()
        self.name = ArkonName.makeName()
        self.birthday = TimeInterval(Census.shared.localTime)
    }

    private static func getNextFishNumber() -> Int {
        defer { Fishday.TheFishNumber += 1 }
        return Fishday.TheFishNumber
    }
}

class Census {
    static var shared: Census!

    let censusData = CensusData()

//    let ageFormatter: DateComponentsFormatter
    private(set) var highWaterAge = 0
    private(set) var highWaterCOffspring = 0
    private(set) var highWaterPopulation = 0

    private(set) var births = 0
    private(set) var cLiveNeurons = 0
    private(set) var localTime = 0
    private(set) var population = 0
    var populated = false

//    let rBirths: Reportoid
//    let rPopulation: Reportoid
//    let rHighWaterAge: Reportoid
//    let rHighWaterPopulation: Reportoid
//    let rCOffspring: Reportoid

    // Markers for said arkons, not the arkons themselves
    var oldestLivingMarker, aimestLivingMarker, busiestLivingMarker: SKSpriteNode?

    var tickTimer: Timer!

    static let dispatchQueue = DispatchQueue(
        label: "ak.census.q",
        target: DispatchQueue.global()
    )

    init(_ scene: ArkoniaScene) {
//        rBirths = scene.reportSundry.reportoid(1)
//
//        rPopulation = scene.reportArkonia.reportoid(2)
//
//        rHighWaterPopulation = scene.reportMisc.reportoid(2)
//        rHighWaterAge = scene.reportMisc.reportoid(1)
//
//        ageFormatter = DateComponentsFormatter()
//
//        ageFormatter.allowedUnits = [.minute, .second]
//        ageFormatter.allowsFractionalUnits = true
//        ageFormatter.unitsStyle = .positional
//        ageFormatter.zeroFormattingBehavior = .pad
//
//        rCOffspring = scene.reportMisc.reportoid(3)
//
//        oldestLivingMarker = SpriteFactory.shared.markersPool.makeSprite()
//        aimestLivingMarker = SpriteFactory.shared.markersPool.makeSprite()
//        busiestLivingMarker = SpriteFactory.shared.markersPool.makeSprite()
//
//        [
//            (oldestLivingMarker!, SKColor.yellow),
//            (aimestLivingMarker!, SKColor.orange),
//            (busiestLivingMarker!, SKColor.green)
//        ].forEach {
//            $0.0.color = $0.1; $0.0.zPosition = 10; $0.0.zRotation = CGFloat.tau / 2
//        }

        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Census.dispatchQueue.async { self.updateReports() }
        }
    }

    func reSeedWorld() { populated = false }
}

extension Census {
    static func getAge(of arkon: Stepper, at currentTime: Int) -> TimeInterval {
        return TimeInterval(currentTime) - arkon.fishday.birthday
    }
}

extension Census {
    func updateReports(_ worldClock: Int) {
        censusData.compress(TimeInterval(worldClock))

//        self.rCOffspring.data.text = String(format: "%d", highWaterCOffspring)
//        self.rHighWaterPopulation.data.text = String(highWaterPopulation)
//        self.rPopulation.data.text = String(population)
//        self.rBirths.data.text = String(births)

//        rHighWaterAge.data.text = ageFormatter.string(from: Double(highWaterAge))

//        markExemplars()

        localTime = worldClock
        Debug.log(level: 155) { "updateReports highwaterAge = \(highWaterAge)" }
    }

    func registerDeath(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        Debug.log(level: 205) { "registerDeath.0; population \(self.population)" }
        Census.registerDeath(stepper, onComplete)
    }
}

private extension Census {
    func markExemplars() {
//        guard let stats = censusData.stats,
//            let oa = stats.oldestArkon, let be = stats.bestAimArkon,
//            let bu = stats.busiestArkon
//            else { return }
//
//        let dataDriven = [
//           (oldestLivingMarker!, oa, Double(stats.maxAge)),
//            (aimestLivingMarker!, be, stats.maxFoodHitRate),
//            (busiestLivingMarker!, bu, Double(stats.maxCOffspring))
//        ]
//
//        dataDriven.forEach { updateMarkerIf($0.0, $0.1.nose) }
    }

    func updateMarkerIf(_ marker: SKSpriteNode, _ markCandidate: SKSpriteNode) {
        if marker.parent != nil {
            marker.removeFromParent()
        }

        markCandidate.addChild(marker)
    }
}

extension Census {
    func registerBirth(_ myNetStructure: NetStructure, _ myParent: Stepper?) -> Fishday {
        self.population += 1
        self.births += 1
        self.highWaterPopulation = max(self.highWaterPopulation, self.population)

        self.cLiveNeurons += myNetStructure.cNeurons

        myParent?.cOffspring += 1

        self.highWaterCOffspring = max(
            myParent?.cOffspring ?? 0, self.highWaterCOffspring
        )

        Debug.log(level: 205) { "registerBirth; population \(self.population)" }

        return Fishday(cNeurons: myNetStructure.cNeurons)
    }

    func registerDeath(_ stepper: Stepper, _ worldTime: TimeInterval) {
        Debug.log(level: 205) { "registerDeath.1; population \(self.population)" }

        self.cLiveNeurons -= stepper.net.netStructure.cNeurons

        highWaterAge = max(highWaterAge, Int(censusData.stats?.maxAge ?? 0))
        population -= 1

        Debug.log(level: 205) { "registerDeath.2; population \(self.population)" }
    }
}
