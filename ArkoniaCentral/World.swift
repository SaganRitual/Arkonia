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

    private func lockWorld(
        _ execute: @escaping Lockable<Void>.LockExecute,
        _ callback: @escaping Lockable<Void>.LockExecute) {
        Lockable<Void>(lockWorldQueue).lock(execute, callback)
    }
}

//
// - Population
//
extension World {

    enum PopulationAction { case decrement, get, increment, incrementCOffspring }

    private func doPopulationStuff(
        do whichStuff: PopulationAction = .get,
        execute: Lockable<Int>.LockExecute? = nil,
        callback: Lockable<Int>.LockCompletion3? = nil
    ) {
        var safeCopyCOffspring = 0
        var safeCopyHiwater = 0
        var safeCopyPop = 0

        lockWorld({
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

            safeCopyCOffspring = self.maxCOffspring
            safeCopyPop = self.population
            safeCopyHiwater = self.maxPopulation
        }, {
            callback?(safeCopyPop, safeCopyHiwater, safeCopyCOffspring)
        })
    }

    func decrementPopulation() { doPopulationStuff(do: .decrement) }

    func getPopulation(callback: @escaping Lockable<Int>.LockCompletion3) {
        doPopulationStuff(do: .get, callback: callback)
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
        execute: Lockable<Selectoid>.LockExecute? = nil,
        callback: Lockable<Int>.LockCompletion? = nil
    ) {
        var newCOffspring = 0

        lockWorld({
            switch whichStuff {
            case .get:
                break

            case .set:
                let selectoid = execute!()
                selectoid.cOffspring += 1
                newCOffspring = selectoid.cOffspring
                World.shared.maxCOffspring = max(newCOffspring, World.shared.maxCOffspring)
            }
        }, {
            callback?(newCOffspring)
        })
    }

    func getMaxCOffspring(callback: @escaping Lockable<Int>.LockCompletion) {
        doDuggarnessStuff(do: .get, callback: callback)
    }

    func incrementCOffspring(for selectoid: Selectoid) {
        func execute() -> Selectoid { return selectoid }
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
        callback: Lockable<TimeInterval>.LockCompletion? = nil
    ) {
        var safeCopyCurrentTime: TimeInterval = 0

        lockWorld({
            switch whichStuff {
            case .get:
                break

            case .set:
                self.currentTime = execute!()
            }

            safeCopyCurrentTime = self.currentTime
        }, {
            callback?(safeCopyCurrentTime)
        })
    }

    func getCurrentTime(
        callback: @escaping Lockable<TimeInterval>.LockCompletion
    ) {
        doCurrentTimeStuff(do: .get, callback: callback)
    }

    func setCurrentTime(to newTime: TimeInterval) {
        func execute() -> TimeInterval { return newTime }
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
        execute: Lockable<TimeInterval>.LockExecute? = nil,
        callback: Lockable<TimeInterval>.LockCompletion2? = nil
    ) {
        var safeCopyMaxLiving: TimeInterval = 0
        var safeCopyHiwater: TimeInterval = 0

        lockWorld({
            switch whichStuff {
            case .get:
                break

            case .set:
                self.maxLivingAge = execute!()

                if self.maxLivingAge > self.highWaterAge {
                    self.highWaterAge = self.maxLivingAge
                }
            }

            safeCopyMaxLiving = self.maxLivingAge
            safeCopyHiwater = self.highWaterAge
        }, {
            callback?(safeCopyMaxLiving, safeCopyHiwater)
        })
    }

    func getAges(callback: @escaping Lockable<TimeInterval>.LockCompletion2) {
        doAgeStuff(do: .get, callback: callback)
    }

    func setMaxLivingAge(
        to newMax: TimeInterval,
        callback: @escaping Lockable<TimeInterval>.LockCompletion2
    ) {
        func execute() -> TimeInterval { return newMax }
        doAgeStuff(do: .set, execute: execute, callback: callback)
    }
}
