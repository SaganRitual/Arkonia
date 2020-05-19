import SpriteKit

struct Fishday {
    let birthday: Int
    let cNeurons: Int
    let fishNumber: Int
}

class Census {
    static var shared: Census!

    let ageFormatter: DateComponentsFormatter
    var archive = [ArkonName: Fishday]()
    private(set) var highWaterAge = 0
    private(set) var highWaterCOffspring = 0
    private(set) var highWaterPopulation = 0

    private(set) var births = 0
    private(set) var cLiveNeurons = 0
    private var localTime = 0
    private(set) var population = 0

    let rBirths: Reportoid
    let rPopulation: Reportoid
    let rHighWaterAge: Reportoid
    let rHighWaterPopulation: Reportoid
    let rCOffspring: Reportoid
    private var TheFishNumber = 0

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

        Arkonia.tickTheWorld(Census.dispatchQueue, WorkItems.updateReports)
    }
}

extension Census {
    func getNextFishNumber(_ onComplete: @escaping (Int) -> Void) {
        Census.dispatchQueue.async {
            let next = self.getNextFishNumber()
            onComplete(next)
        }
    }

    private func getNextFishNumber() -> Int {
        defer { self.TheFishNumber += 1 }
        return self.TheFishNumber
    }

    static func getAge(of arkon: ArkonName, at currentTime: Int, require: Bool = true) -> Int? {
        if let birthday = Census.shared.archive[arkon]?.birthday {
            return currentTime - birthday
        } else {
            if require { fatalError() }
            return nil
        }
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
        WorkItems.registerDeath(stepper, onComplete)
    }
}

extension Census {
    func registerBirth(_ myName: ArkonName, _ myParent: Stepper?, _ myNet: Net?) -> Fishday {
        self.population += 1
        self.births += 1
        self.highWaterPopulation = max(self.highWaterPopulation, self.population)

        let n = myNet?.cNeurons ?? 0
        self.cLiveNeurons += n

        myParent?.cOffspring += 1

        self.highWaterCOffspring = max(
            myParent?.cOffspring ?? 0, self.highWaterCOffspring
        )

        Debug.log(level: 89) {
            "nil? \(myParent == nil), pop \(self.population)"
            + ", cOffspring \(myParent?.cOffspring ?? -1)" +
            " real hw cOfspring \(self.highWaterCOffspring)"
        }

        archive[myName] = Fishday(
            birthday: self.localTime,
            cNeurons: myNet?.cNeurons ?? 0, // How would we ever not have a net? Looks like code rot to me
            fishNumber: self.getNextFishNumber()
        )

        return archive[myName]!
    }

    func registerDeath(_ nameOfDeceased: ArkonName, _ cNeuronsOfDeceased: Int, _ worldTime: Int) {
        guard let ageOfDeceased = Census.getAge(of: nameOfDeceased, at: worldTime) else { fatalError() }

        highWaterAge = max(highWaterAge, ageOfDeceased)
        population -= 1

        self.cLiveNeurons -= cNeuronsOfDeceased

        archive.removeValue(forKey: nameOfDeceased)

        if archive.isEmpty {
            ArkoniaScene.shared.speed = 0
            ArkoniaScene.shared.lgNeurons.canvases.forEach { canvas in canvas.speed = 0 }
            Clock.stop()
        }
    }
}
