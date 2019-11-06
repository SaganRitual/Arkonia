import Foundation

typealias GoCall = () -> Void

protocol Dispatchable {
    var runType: Dispatch.RunType { get set }

    func go()
}

extension Dispatchable {
    var runType: Dispatch.RunType { return .barrier }
}

enum DispatchMode { case alive, apoptosisScheduled }

final class Dispatch {
    enum RunType { case serial, concurrent, barrier }

    var currentTask: Dispatchable!
    var dispatchMode: DispatchMode = .alive
    let name = UUID().uuidString
    var reentered = false
    weak var stepper: Stepper!

    init(_ stepper: Stepper? = nil) {
        self.stepper = stepper
    }

    private func go(_ dispatchable: Dispatchable) {
        switch dispatchable.runType {
        case .barrier:    runBarrier(dispatchable)
        case .concurrent: runConcurrent(dispatchable)
        case .serial:     runSerial(dispatchable)
        }
    }

    private func runBarrier(_ dispatchable: Dispatchable) {
        Grid.shared.concurrentQueue.async(flags: DispatchWorkItemFlags.barrier) {
            if self.dispatchMode == .apoptosisScheduled { return }
            dispatchable.go()
        }
    }

    private func runConcurrent(_ dispatchable: Dispatchable) {
        Grid.shared.concurrentQueue.async(flags: DispatchWorkItemFlags()) {
            if self.dispatchMode == .apoptosisScheduled { return }
            dispatchable.go()
        }
    }

    private func runSerial(_ dispatchable: Dispatchable) {
        Grid.shared.serialQueue.async {
            if self.dispatchMode == .apoptosisScheduled { return }
            dispatchable.go()
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
        guard let spentShift = currentTask as? Shift else { fatalError() }

        let shiftTracker = spentShift.getResult()

        currentTask = Eat(self)

        guard let newEat = currentTask as? Eat else { fatalError() }
        newEat.inject(shiftTracker)
        start(newEat)
    }

    func funge() {
        currentTask = Funge(self)
        start(currentTask)
    }

    func metabolize() {
        currentTask = Metabolize(self)
        start(currentTask)
    }

    func parasitize() {
        guard let activeEat = currentTask as? Eat else { fatalError() }
        guard let (_, victim) = activeEat.getResult() else { fatalError() }

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
