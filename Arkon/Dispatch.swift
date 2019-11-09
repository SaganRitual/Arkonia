import Foundation

typealias GoCall = () -> Void

protocol Dispatchable {
    var runType: Dispatch.RunType { get set }

    func go()
}

extension Dispatchable {
    var runType: Dispatch.RunType { return .barrier }
}

final class Dispatch {
    enum RunType { case serial, concurrent, barrier }

    var battle_: (Stepper, Stepper)?
    var battle: (Stepper, Stepper)? {
        get { return Grid.shared.serialQueue.sync { battle_ } }
        set { Grid.shared.serialQueue.sync { battle_ = newValue } }
    }

    var currentTask: Dispatchable!
    var gridletEngager: Gridlet.Engager!
    let name = UUID().uuidString
    weak var stepper: Stepper!

    init(_ stepper: Stepper? = nil) {
        self.stepper = stepper
    }

    private func go(_ dispatchable: Dispatchable) {
        if let (victor, victim) = battle {
            settleCombat(victor, victim)
            return
        }

        switch dispatchable.runType {
        case .barrier:    runBarrier(dispatchable)
        case .concurrent: runConcurrent(dispatchable)
        case .serial:     runSerial(dispatchable)
        }
    }

    private func runBarrier(_ dispatchable: Dispatchable) {
        Grid.shared.concurrentQueue.async(flags: DispatchWorkItemFlags.barrier) {
            dispatchable.go()
        }
    }

    private func runConcurrent(_ dispatchable: Dispatchable) {
        Grid.shared.concurrentQueue.async(flags: DispatchWorkItemFlags()) {
            dispatchable.go()
        }
    }

    private func runSerial(_ dispatchable: Dispatchable) {
        Grid.shared.serialQueue.async {
            dispatchable.go()
        }
    }

    private func settleCombat(_ victor: Stepper, _ victim: Stepper) {
        battle = nil

        victor.dispatch.parasitize()
        victim.dispatch.apoptosize()
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
        currentTask = Colorize(self)
        start(currentTask)
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
        guard let (_, victim) = self.battle else { fatalError() }

        currentTask = Parasitize(self)

        guard let newParasitize = currentTask as? Parasitize else { fatalError() }
        newParasitize.inject(victim)
        start(newParasitize)
    }

    func shift() {
        currentTask = Shift(self)
        start(currentTask)
    }

    func wangkhi() {
        currentTask = WangkhiEmbryo(self)
        start(currentTask)
    }
}
