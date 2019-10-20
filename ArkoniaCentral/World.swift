import SpriteKit

let asyncQueue = DispatchQueue(
    label: "arkonia.asynq", qos: .default,
    attributes: DispatchQueue.Attributes.concurrent
)

let lockWorldQueue = DispatchQueue(
    label: "arkonia.lock.world", qos: .default,
    attributes: DispatchQueue.Attributes.concurrent,
    target: DispatchQueue.global()
)

extension World.Lockable {
    typealias LockExecute = Dispatch.Lockable<T>.LockExecute
    typealias LockOnComplete = Dispatch.Lockable<T>.LockOnComplete
}

class World {
    static let mutator = Mutator()
    static var shared = World()

    private var currentTime: TimeInterval = 0
    private var population = 0
    private var maxPopulation = 0

    private var highWaterAge = TimeInterval(0)
    private var maxLivingAge = TimeInterval(0)
    private var maxCOffspring = 0

    private let timeLimit: TimeInterval? = 10000

    class Lockable<T>: Dispatch.Lockable<T> {}

    static private func lock<T>(
        _ execute: Lockable<T>.LockExecute? = nil,
        _ userOnComplete: Lockable<T>.LockOnComplete? = nil,
        _ completionMode: Dispatch.CompletionMode = .concurrent
    ) {
        Lockable<T>(lockWorldQueue).lock(
            execute, userOnComplete, completionMode
        )
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

            case .increment:
                self.population += 1
                if self.population > self.maxPopulation { self.maxPopulation = self.population }

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

    func getPopulation(onComplete: @escaping World.Lockable<Int>.LockOnComplete) {
        doPopulationStuff(do: .get, onComplete: onComplete)
    }

    func incrementPopulation() { doPopulationStuff(do: .increment) }
}

//
// - Duggarness
//
extension World {
    enum DuggarnessAction { case get, set }

    private func doDuggarnessStuff(
        do whichStuff: CurrentTimeAction = .get,
        execute: World.Lockable<Selectoid>.LockExecute? = nil,
        onComplete: World.Lockable<Int>.LockOnComplete? = nil
    ) {
        World.lock({
            var newCOffspring = 0

            switch whichStuff {
            case .get:
                break

            case .set:
                guard let ex = execute else { fatalError() }
                guard let ss = ex() else { fatalError() }

                let selectoid = ss[0]
                selectoid.cOffspring += 1
                newCOffspring = selectoid.cOffspring
                World.shared.maxCOffspring = max(newCOffspring, World.shared.maxCOffspring)
            }

            return [newCOffspring]
        }, {
            cOffspring in onComplete?(cOffspring)
        })
    }

    func getMaxCOffspring(onComplete: @escaping World.Lockable<Int>.LockOnComplete) {
        doDuggarnessStuff(do: .get, onComplete: onComplete)
    }

    func incrementCOffspring(for selectoid: Selectoid) {
        func execute() -> [Selectoid] { return [selectoid] }
        doDuggarnessStuff(do: .set, execute: execute)
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
