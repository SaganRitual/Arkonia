import Dispatch

protocol StatsProtocol {
    var currentPopulation: Int { get }
    var currentTime: Int { get }
    var highWaterPopulation: Int { get }
    var maxCOffspringForLiving: Int { get }
    var maxLivingAge: Int { get }
    var highWaterAge: Int { get }
    var highWaterCOffspring: Int { get }
}

extension World {
    static let stats = Stats()

    struct StatsCopy: StatsProtocol {
        let currentPopulation: Int
        let currentTime: Int
        let highWaterPopulation: Int
        let maxCOffspringForLiving: Int
        let maxLivingAge: Int
        let highWaterAge: Int
        let highWaterCOffspring: Int
    }

    class Stats: StatsProtocol {
        private var TheFishNumber = 0

        private(set) var currentPopulation = 0
        private(set) var currentTime = 0
        private(set) var highWaterPopulation = 0
        private(set) var maxCOffspringForLiving = 0
        private(set) var maxLivingAge = 0
        private(set) var highWaterAge = 0
        private(set) var highWaterCOffspring = 0

        private let lockQueue = DispatchQueue(
            label: "arkonia.lock.world.stats", qos: .utility,
            attributes: DispatchQueue.Attributes.concurrent,
            target: DispatchQueue.global()
        )

        var gameAge: Int { return currentTime }

        init() { updateWorldClock() }

        func copy() -> StatsCopy {
            return StatsCopy(
                currentPopulation: self.currentPopulation,
                currentTime: self.currentTime,
                highWaterPopulation: self.highWaterPopulation,
                maxCOffspringForLiving: self.maxCOffspringForLiving,
                maxLivingAge: self.maxLivingAge,
                highWaterAge: self.highWaterAge,
                highWaterCOffspring: self.highWaterCOffspring
            )
        }
    }
}

extension World.Stats {
    typealias OCGetStats = (World.StatsCopy) -> Void

    func decrementPopulation(_ onComplete: OCGetStats?) {
        lockQueue.async(flags: .barrier) { [unowned self] in
            self.currentPopulation -= 1
            onComplete?(self.copy())
        }
    }

    func getNextFishNumber(_ onComplete: @escaping (Int) -> Void) {
        lockQueue.async(flags: .barrier) {
            defer { World.stats.TheFishNumber += 1 }
            onComplete(World.stats.TheFishNumber)
        }
    }

    func getStats(_ onComplete: @escaping OCGetStats) {
        lockQueue.async(flags: .barrier) { onComplete(self.copy()) }
    }

    func getTimeSince(_ time: Int, _ onComplete: @escaping (Int) -> Void) {
        lockQueue.async(flags: .barrier) {
            onComplete(self.currentTime - time)
        }
    }

    func incrementPopulation(_ onComplete: @escaping OCGetStats) {
        lockQueue.async(flags: .barrier) { [unowned self] in
            self.currentPopulation += 1
            self.highWaterPopulation = max(self.currentPopulation, self.highWaterPopulation)
            onComplete(self.copy())
        }
    }

    func registerAge(_ age: Int, _ onComplete: @escaping OCGetStats) {
        lockQueue.async(flags: .barrier) {
            self.maxLivingAge = max(age, self.maxLivingAge)
            self.highWaterAge = max(self.maxLivingAge, self.highWaterAge)
            onComplete(self.copy())
        }
    }

    func registerBirth(
        myParent: Stepper?,
        meOffspring: WangkhiProtocol,
        _ onComplete: @escaping () -> Void
    ) {
        lockQueue.async(flags: .barrier) {
            [unowned self] in self.registerBirth_(myParent: myParent, meOffspring: meOffspring)
        }
    }

    func registerBirth_(myParent: Stepper?, meOffspring: WangkhiProtocol) {
        self.currentPopulation += 1

        myParent?.cOffspring += 1

        meOffspring.fishNumber = self.TheFishNumber
        self.TheFishNumber += 1

        meOffspring.birthday = self.currentTime

        self.maxCOffspringForLiving = max(
            (myParent?.cOffspring ?? 0), self.maxCOffspringForLiving
        )

        self.highWaterCOffspring = max(
            self.maxCOffspringForLiving, self.highWaterCOffspring
        )
    }

    private func updateWorldClock() {
        lockQueue.async(flags: .barrier) { [unowned self] in
            self.currentTime += 1

            self.lockQueue.asyncAfter(deadline: DispatchTime.now() + 1) {
                [unowned self] in self.updateWorldClock()
            }
        }
    }

}
