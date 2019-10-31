import Foundation

typealias GoCall = () -> Void

protocol Dispatchable {
    func go()
}

enum DispatchMode: UInt {
    case alive         = 0b0000_0001
    case dead          = 0b0000_0010
    case dying         = 0b0000_0100
    case killRequested = 0b0000_1000
    case killScheduled = 0b0001_0000
    case running       = 0b0010_0000

    static let dmAlive = DispatchMode.alive.rawValue | DispatchMode.running.rawValue
}

final class Dispatch {
    var currentTask: Dispatchable!
    var dispatchMode: DispatchMode = .alive
    let name = UUID().uuidString
    var runningAsBarrier = true

//    var tempStrongReference: Stepper?
    weak var stepper: Stepper!

    init(_ stepper: Stepper? = nil) {
//        print("Dispatch(\(stepper == nil))")
        self.stepper = stepper
//        self.tempStrongReference = stepper
    }

    private func go(_ call: GoCall? = nil, runAsBarrier: Bool = true) {
//        print("k1 \(stepper?.name ?? "<nouthing>")")

        let flags = runAsBarrier ? .barrier : DispatchWorkItemFlags.barrier //DispatchWorkItemFlags()
        Grid.lockQueue.async(flags: flags) {
            assert(self.runningAsBarrier == true)
            self.runningAsBarrier = runAsBarrier

            if self.dispatchMode == .killScheduled || self.dispatchMode == .dead { return }
            assert(self.dispatchMode == .alive)

            let runComponent: GoCall = call ?? self.apoptosize

//            print("a1")
            runComponent()
//            print("a2")
        }
//        print("og")
    }

    func start(_ dispatchable: Dispatchable, runAsBarrier: Bool = true) {
//        print("st")
        go(dispatchable.go, runAsBarrier: true)
    }

    func callAgain(runAsBarrier: Bool = true) {
//        print("ca")
        go(self.currentTask.go, runAsBarrier: true)
    }

    deinit {
//        print("~Dispatch?")
    }
}

extension Dispatch {
    func apoptosize() {
        currentTask = Apoptosize(self)
        start(currentTask)
    }

    func colorize() {
//        print("c1, \(stepper?.name ?? "<nothing>")")
        currentTask = Colorize(self)
//        print("c2, \(stepper?.name ?? "<nothing>")")
        start(currentTask)
//        print("c3, \(stepper?.name ?? "<nothing>")")
    }

    func defeatManna() {
        guard let activeEat = currentTask as? Eat else { fatalError() }
        let manna: Manna = activeEat.getResult()

        activeEat.inject(manna)
        start(activeEat)
    }

    func eat() {
        guard let currentGridlet = stepper.gridlet else { fatalError() }
        guard let spentShift = currentTask as? Shift else { fatalError() }
        guard let previousGridlet = spentShift.getResult() else { fatalError() }

        currentTask = Eat(self)

        guard let newEat = currentTask as? Eat else { fatalError() }
        newEat.inject(previousGridlet, currentGridlet)
        start(newEat)
    }

    func funge() {
//        print("f1, \(stepper?.name ?? "<nothing>")")
        currentTask = Funge(self)
//        print("f2, \(stepper?.name ?? "<nothing>")")
        start(currentTask)
//        print("f3, \(stepper?.name ?? "<nothing>")")
    }

    func metabolize() {
//        print("m1, \(stepper?.name ?? "<nothing>")")
        currentTask = Metabolize(self)
//        print("m2, \(stepper?.name ?? "<nothing>")")
        start(currentTask)
//        print("m3, \(stepper?.name ?? "<nothing>")")
    }

    func parasitize() {
        guard let activeEat = currentTask as? Eat else { fatalError() }
        let (_, victim) = activeEat.getResult()

        currentTask = Parasitize(self)

        guard let newParasitize = currentTask as? Parasitize else { fatalError() }
        newParasitize.inject(victim)
        start(newParasitize)
    }

    func shift() {
//        print("s1, \(stepper?.name ?? "<nothing>")")
        currentTask = Shift(self)
//        print("s2, \(stepper?.name ?? "<nothing>")")
        start(currentTask)
//        print("s3, \(stepper?.name ?? "<nothing>")")
    }

    func wangkhi() {
//        print("w1, \(stepper?.name ?? "<nothing>")")
        currentTask = WangkhiEmbryo(self)
//        print("w2, \(stepper?.name ?? "<nothing>")")
        start(currentTask)
//        print("w3, \(stepper?.name ?? "<nothing>")")
    }
}
