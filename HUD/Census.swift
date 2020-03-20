import SpriteKit

struct Fishday {
    let fishNumber: Int
    let birthday: Int
}

class Census {
    static var shared: Census!

    let ageFormatter: DateComponentsFormatter
    var archive = [String: Fishday]()
    private(set) var highWaterAge = 0
    private(set) var highWaterCOffspring = 0
    private(set) var highWaterPopulation = 0
    private var localTime = 0
    private(set) var population = 0
    private(set) var births = 0

    let rBirths: Reportoid
    let rNextBlast: Reportoid
    let rPopulation: Reportoid
    let rHighWaterAge: Reportoid
    let rHighWaterPopulation: Reportoid
    let rCOffspring: Reportoid
    private var TheFishNumber = 0

    static let dispatchQueue = DispatchQueue(
        label: "ak.census.q",
        target: DispatchQueue.global(qos: .utility)
    )

    init(_ scene: GriddleScene) {
        rBirths = scene.reportHistory.reportoid(1)
        rNextBlast = scene.reportHistory.reportoid(2)

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

    static func getAge(of arkon: String, at currentTime: Int) -> Int {
        return currentTime - Census.shared.archive[arkon]!.birthday
    }
}

extension Census {
    func updateReports(_ ages: [Int], _ worldClock: Int) {
        if ages.isEmpty { return }

        var greatestAge: Int = 0
        var toNextBlast: TimeInterval = 0

        func a() {
            greatestAge = ages.last!

            self.rCOffspring.data.text = String(format: "%d", highWaterCOffspring)
            self.rHighWaterPopulation.data.text = String(highWaterPopulation)
            self.rPopulation.data.text = String(population)
            self.rBirths.data.text = String(births)

            MannaCannon.shared!.replantDispatch.sync {
                let now = Date()
                toNextBlast = now.distance(to: MannaCannon.shared!.nextBlast)
                Debug.log(level: 133) { "update toNextBlast = \(toNextBlast), now = \(now), next = \(MannaCannon.shared!.nextBlast)" }
                b()
            }
        }

        func b() {
            self.rNextBlast.data.text = ageFormatter.string(from: Double(max(toNextBlast, 0)))

            let n = max(greatestAge, highWaterAge)
            rHighWaterAge.data.text = ageFormatter.string(from: Double(n))

            localTime = worldClock
        }

        a()
    }

    func registerDeath(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        WorkItems.registerDeath(stepper, onComplete)
    }
}

extension Census {
    func registerBirth(_ myName: String, _ myParent: Stepper?) -> Fishday {
        self.population += 1
        self.births += 1
        self.highWaterPopulation = max(self.highWaterPopulation, self.population)

        myParent?.cOffspring += 1

        self.highWaterCOffspring = max(
            myParent?.cOffspring ?? 0, self.highWaterCOffspring
        )

        Debug.log(level: 89) {
            "nil? \(myParent == nil), pop \(self.population)"
            + ", cOffspring \(myParent?.cOffspring ?? -1)" +
            " real hw cOfspring \(self.highWaterCOffspring)"
        }

        archive[myName] = Fishday(fishNumber: self.getNextFishNumber(), birthday: self.localTime)
        return archive[myName]!
    }

    func registerDeath(_ nameOfDeceased: String, _ worldTime: Int) {
        let ageOfDeceased = Census.getAge(of: nameOfDeceased, at: worldTime)

        highWaterAge = max(highWaterAge, ageOfDeceased)
        population -= 1
    }
}
