import Foundation

class World {
    static let mutator = Mutator()
    static var shared = World()

    var population = 0 { willSet { if newValue > maxPopulation { maxPopulation = newValue } } }
    private(set) var maxPopulation = 0

    static let currentTimeSemaphore = DispatchSemaphore(value: 1)

    private var currentTime_: TimeInterval = 0
    var currentTime: TimeInterval {
        get {
            World.currentTimeSemaphore.wait()
            defer { World.currentTimeSemaphore.signal() }
            return currentTime_
        }

        set {
            World.currentTimeSemaphore.wait()
            defer { World.currentTimeSemaphore.signal() }
            currentTime_ = newValue
        }
    }

    var greatestLiveAge = TimeInterval(0)
    var maxAge = TimeInterval(0)
    var maxCOffspring = 0
    var timeZero: TimeInterval = 0

    var gameAge: TimeInterval { return World.shared.currentTime - World.shared.timeZero }

    let timeLimit: TimeInterval? = 10000
    public var entropy: TimeInterval {
//        guard let t = timeLimit else { return 0 }
//        return min(World.shared.gameAge / t, 1.0)
        return 0.0  // No entropy
    }

    public var foodValue: CGFloat {
        return 1 - CGFloat(entropy)
    }

    func registerAge(_ age: TimeInterval) {
        maxAge = max(maxAge, age)
    }

    func registerCOffspring(_ cOffspring: Int) {
        maxCOffspring = max(maxCOffspring, cOffspring)
    }
}
