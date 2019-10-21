import SpriteKit

extension World.Lockable {
    typealias LockExecute = Dispatch.Lockable<T>.LockExecute
    typealias LockOnComplete = Dispatch.Lockable<T>.LockOnComplete
}

class World {
    static let mutator = Mutator()
    static var shared = World()

    private static var TheFishNumber = 0

    private var currentTime: TimeInterval = 0
    private var population = 0
    private var maxPopulation = 0

    private var highWaterAge = TimeInterval(0)
    private var maxLivingAge = TimeInterval(0)
    private var maxCOffspring = 0

    private let timeLimit: TimeInterval? = 10000

    class Lockable<T>: Dispatch.Lockable<T> {}

    static let mainQueue = DispatchQueue(
        label: "arkonia.main.asynq", qos: .default,
        attributes: DispatchQueue.Attributes.concurrent
    )

    static let lockQueue = DispatchQueue(
        label: "arkonia.lock.world", qos: .default,
        attributes: DispatchQueue.Attributes.concurrent,
        target: DispatchQueue.global()
    )

    static func lock<T>(
        _ execute: Lockable<T>.LockExecute? = nil,
        _ userOnComplete: Lockable<T>.LockOnComplete? = nil,
        _ completionMode: Dispatch.CompletionMode = .concurrent
    ) {
        Lockable<T>(World.lockQueue).lock(
            execute, userOnComplete, completionMode
        )
    }

    static func run(_ execute: @escaping () -> Void) {
        World.mainQueue.async(execute: execute)
    }

    static func runAfter(
        deadline: DispatchTime, _ execute: @escaping () -> Void
    ) {
        World.mainQueue.asyncAfter(deadline: deadline, execute: execute)
    }
}

//
// - Population
//
extension World {

    enum PopulationAction { case decrement, get, increment, incrementCOffspring }

    private func doPopulationStuff(
        do whichStuff: PopulationAction = .get,
        execute: World.Lockable<Int>.LockExecute? = nil,
        onComplete: World.Lockable<Int>.LockOnComplete? = nil
    ) {
        World.lock({
            switch whichStuff {
            case .decrement:
                self.population -= 1

            case .get:
                break

            case .increment: self.incrementPopulation_()

            case .incrementCOffspring:
                self.maxCOffspring += 1
            }

            return [self.maxCOffspring, self.population, self.maxPopulation]
        }, {
            onComplete?($0)
        },
           .concurrent
        )
    }

    func decrementPopulation() { doPopulationStuff(do: .decrement) }

    func getFishNumber_() -> Int {
        defer { World.TheFishNumber += 1 }
        return World.TheFishNumber
    }

    func getPopulation(onComplete: @escaping World.Lockable<Int>.LockOnComplete) {
        doPopulationStuff(do: .get, onComplete: onComplete)
    }

    func incrementPopulation() { doPopulationStuff(do: .increment) }

    func incrementPopulation_() {
        self.population += 1
        if self.population > self.maxPopulation { self.maxPopulation = self.population }
    }
}

//
// - Duggarness
//
extension World {

    func getMaxCOffspring(onComplete: @escaping ([Int]?) -> Void) {

        func workItem() -> [Int]? { return [World.shared.maxCOffspring] }
        World.lock(workItem, onComplete)
    }

    func registerCOffspring_(_ newCOffspring: Int) {
        World.shared.maxCOffspring = max(newCOffspring, World.shared.maxCOffspring)
    }
}

//
// - Time
//
extension World {

    enum CurrentTimeAction { case get, set }

    private func doCurrentTimeStuff(
        do whichStuff: CurrentTimeAction = .get,
        execute: Lockable<TimeInterval>.LockExecute? = nil,
        onComplete: Lockable<TimeInterval>.LockOnComplete? = nil
    ) {
        World.lock({ () -> [TimeInterval] in
            switch whichStuff {
            case .get:
                break

            case .set:
                guard let ex = execute else { fatalError() }
                guard let tt = ex() else { fatalError() }

                self.currentTime = tt[0]
            }

            return [self.currentTime]
        }, {
            currentTimes in onComplete?(currentTimes)
        },
           .continueBarrier
        )
    }

    func getCurrentTime_() -> TimeInterval { return self.currentTime }
    func setCurrentTime_(_ newTime: TimeInterval) { self.currentTime = newTime }

    func getCurrentTime(
        onComplete: @escaping World.Lockable<TimeInterval>.LockOnComplete
    ) {
        doCurrentTimeStuff(do: .get, onComplete: onComplete)
    }

    func setCurrentTime(to newTime: TimeInterval) {
        func execute() -> [TimeInterval]? { return [newTime] }
        doCurrentTimeStuff(do: .set, execute: execute)
    }
}

//
// - Ages
//

extension World {

    enum AgeAction { case get, set }

    private func doAgeStuff(
        do whichStuff: AgeAction = .get,
        execute: World.Lockable<TimeInterval>.LockExecute? = nil,
        onComplete: World.Lockable<TimeInterval>.LockOnComplete? = nil
    ) {
        World.lock({
            switch whichStuff {
            case .get:
                break

            case .set:
                guard let ex = execute else { fatalError() }
                guard let aa = ex() else { fatalError() }

                self.maxLivingAge = aa[0]

                if self.maxLivingAge > self.highWaterAge {
                    self.highWaterAge = self.maxLivingAge
                }
            }

            return [self.maxLivingAge, self.highWaterAge]
        }, {
            ages in onComplete?(ages)
        })
    }

    static func getArkonAge_(birthday: TimeInterval) -> CGFloat {
        return CGFloat(World.shared.getCurrentTime_() - birthday)
    }

    func getAges(onComplete: @escaping World.Lockable<TimeInterval>.LockOnComplete) {
        doAgeStuff(do: .get, onComplete: onComplete)
    }

    func setMaxLivingAge(
        to newMax: TimeInterval,
        onComplete: @escaping World.Lockable<TimeInterval>.LockOnComplete
    ) {
        func execute() -> [TimeInterval]? { return [newMax] }
        doAgeStuff(do: .set, execute: execute, onComplete: onComplete)
    }
}
