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

    let ageFormatter: DateComponentsFormatter
    private(set) var highWaterAge = 0
    private(set) var highWaterCOffspring = 0
    private(set) var highWaterPopulation = 0

    private(set) var births = 0
    private(set) var cLiveNeurons = 0
    private(set) var localTime = 0
    private(set) var population = 0
    var populated = false

    let rBirths: Reportoid
    let rPopulation: Reportoid
    let rHighWaterAge: Reportoid
    let rHighWaterPopulation: Reportoid
    let rCOffspring: Reportoid

    var tickTimer: Timer!

    static let dispatchQueue = DispatchQueue(
        label: "ak.census.q",
        target: DispatchQueue.global()
    )

    init(_ scene: ArkoniaScene) {
        rBirths = scene.reportSundry.reportoid(1)

        rPopulation = scene.reportArkonia.reportoid(2)

        rHighWaterPopulation = scene.reportMisc.reportoid(2)
        rHighWaterAge = scene.reportMisc.reportoid(1)

        ageFormatter = DateComponentsFormatter()

        ageFormatter.allowedUnits = [.minute, .second]
        ageFormatter.allowsFractionalUnits = true
        ageFormatter.unitsStyle = .positional
        ageFormatter.zeroFormattingBehavior = .pad

        rCOffspring = scene.reportMisc.reportoid(3)

        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateReports()
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
        self.rCOffspring.data.text = String(format: "%d", highWaterCOffspring)
        self.rHighWaterPopulation.data.text = String(highWaterPopulation)
        self.rPopulation.data.text = String(population)
        self.rBirths.data.text = String(births)

        rHighWaterAge.data.text = ageFormatter.string(from: Double(highWaterAge))

        localTime = worldClock
        Debug.log(level: 155) { "updateReports highwaterAge = \(highWaterAge)" }
    }

    func registerDeath(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        Debug.log(level: 205) { "registerDeath.0; population \(self.population)" }
        Census.registerDeath(stepper, onComplete)
    }
}

extension Census {
    func registerBirth(_ myParent: Stepper?, _ myNet: Net) -> Fishday {
        self.population += 1
        self.births += 1
        self.highWaterPopulation = max(self.highWaterPopulation, self.population)

        self.cLiveNeurons += myNet.netStructure.cNeurons

        myParent?.cOffspring += 1

        self.highWaterCOffspring = max(
            myParent?.cOffspring ?? 0, self.highWaterCOffspring
        )

        Debug.log(level: 205) { "registerBirth; population \(self.population)" }

        return Fishday(cNeurons: myNet.netStructure.cNeurons)
    }

    func registerDeath(_ stepper: Stepper, _ worldTime: Int) {
        Debug.log(level: 205) { "registerDeath.1; population \(self.population)" }
        let ageOfDeceased = Census.getAge(of: stepper, at: worldTime)

        highWaterAge = max(highWaterAge, Int(ageOfDeceased))
        population -= 1

        if population < 25 { Stepper.makeNewArkon(nil) }

        self.cLiveNeurons -= stepper.net.netStructure.cNeurons

        Debug.log(level: 205) { "registerDeath.2; population \(self.population)" }
    }
}
