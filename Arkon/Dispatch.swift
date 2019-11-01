import Foundation

typealias GoCall = () -> Void

protocol Dispatchable {
    var runAsBarrier: Bool { get }

    func go()
}

extension Dispatchable {
    var runAsBarrier: Bool { return true }
}

enum DispatchMode { case alive, apoptosisScheduled }

final class Dispatch {
    var currentTask: Dispatchable!
    var dispatchMode: DispatchMode = .alive
    let name = UUID().uuidString
    weak var stepper: Stepper!

    init(_ stepper: Stepper? = nil) {
        self.stepper = stepper
    }

    private func go(_ dispatchable: Dispatchable) {
        let queue: DispatchQueue
        let flags: DispatchWorkItemFlags

        if dispatchable.runAsBarrier {
            queue = Grid.lockQueue
            flags = .barrier
        } else {
            queue = World.mainQueue
            flags = DispatchWorkItemFlags()
        }

        queue.async(flags: flags) {
            if self.dispatchMode == .apoptosisScheduled { return }

            let runComponent: GoCall = dispatchable.go
            runComponent()
        }
    }

    func callAgain() { go(self.currentTask) }
    func start(_ dispatchable: Dispatchable) { go(dispatchable) }
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
        currentTask = Funge(self)
        start(currentTask)
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
