import SpriteKit

class Census {
    static var shared: Census!

    let ageFormatter: DateComponentsFormatter
    private(set) var highWaterAge = 0
    private(set) var highWaterCOffspring = 0
    private(set) var highWaterPopulation = 0
    private var localTime = 0
    private(set) var population = 0
    let rPopulation: Reportoid
    let rHighWaterAge: Reportoid
    let rHighWaterPopulation: Reportoid
    let rCOffspring: Reportoid
    private var TheFishNumber = 0

    static let dispatchQueue = DispatchQueue(
        label: "ak.census.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .utility)
    )

    init(_ scene: GriddleScene) {
        rPopulation = scene.reportArkonia.reportoid(2)
        rHighWaterPopulation = scene.reportMisc.reportoid(2)
        rHighWaterAge = scene.reportMisc.reportoid(1)
        ageFormatter = DateComponentsFormatter()

        ageFormatter.allowedUnits = [.minute, .second]
        ageFormatter.allowsFractionalUnits = true
        ageFormatter.unitsStyle = .positional
        ageFormatter.zeroFormattingBehavior = .pad

        rCOffspring = scene.reportMisc.reportoid(3)

        Arkonia.tickTheWorld(Census.dispatchQueue, partA)
    }
}

extension Census {
    func getNextFishNumber(_ onComplete: @escaping (Int) -> Void) {
        Census.dispatchQueue.async(flags: .barrier) {
            let next = self.getNextFishNumber()
            onComplete(next)
        }
    }

    private func getNextFishNumber() -> Int {
        defer { self.TheFishNumber += 1 }
        return self.TheFishNumber
    }
}

extension Arkonia {
    static func tickTheWorld(_ queue: DispatchQueue, _ tick: @escaping () -> Void) {
        // This vomitosis is because I can't figure out how to get
        // asyncAfter to create a barrier task; it just runs concurrently
        // with the others, and causes crashes. Tried with DispatchWorkItem
        // too, but that didn't work even when using async(flags:execute:)
        queue.asyncAfter(deadline: .now() + 1) {
            queue.async(flags: .barrier) { tick(); tickTheWorld(queue, tick) }
        }
    }
}

extension Census {
    private func partA() {
        let ages: [Int] = GriddleScene.arkonsPortal!.children.compactMap { node in
            guard let sprite = node as? SKSpriteNode else { return nil }
            guard let stepper = sprite.getStepper(require: false) else { return nil }
            return stepper.getAge(localTime)
        }.sorted { $0 < $1 }

        if ages.count < 15 {
            for _ in 0..<25 { Dispatch().spawn() }
        }

        if !ages.isEmpty { partB(ages.last!) }
    }

    private func partB(_ greatestAge: Int) {
        self.rCOffspring.data.text = String(format: "%d", highWaterCOffspring)
        self.rHighWaterPopulation.data.text = String(highWaterPopulation)
        self.rPopulation.data.text = String(population)

        let n = max(Double(greatestAge), Double(highWaterAge))
        rHighWaterAge.data.text = ageFormatter.string(from: n)

        updateCensus()
    }
}

extension Census {
    typealias OnComplete0p = () -> Void

    func registerBirth(
        myParent: Stepper?,
        meOffspring: SpawnProtocol,
        _ onComplete: @escaping OnComplete0p
    ) {
        Census.dispatchQueue.async(flags: .barrier) { [unowned self] in
            self.registerBirth(myParent, meOffspring)
            onComplete()
        }
    }

    private func registerBirth(_ myParent: Stepper?, _ meOffspring: SpawnProtocol) {
        self.population += 1
        self.highWaterPopulation = max(self.highWaterPopulation, self.population)

        myParent?.cOffspring += 1
        meOffspring.fishNumber = self.getNextFishNumber()
        meOffspring.birthday = self.localTime

        self.highWaterCOffspring = max(
            myParent?.cOffspring ?? 0, self.highWaterCOffspring
        )

        Log.L.write("nil? \(myParent == nil), pop \(self.population), cOffspring \(myParent?.cOffspring ?? -1)" +
            " real hw cOfspring \(self.highWaterCOffspring)", level: 37)
    }

    func registerDeath(_ birthdayOfDeceased: Int) {
        Census.dispatchQueue.async { [unowned self] in
            let ageOfDeceased = self.localTime - birthdayOfDeceased
            self.highWaterAge = max(self.highWaterAge, ageOfDeceased)
            self.population -= 1
        }
    }
}
