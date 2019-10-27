import Foundation

typealias GoCall = () -> Void

protocol Dispatchable {
    init(_ dispatch: Dispatch)
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
    var runningAsBarrier = false
    weak var stepper: Stepper!

    init(_ stepper: Stepper) { self.stepper = stepper }

    func go(_ call: GoCall? = nil, runAsBarrier: Bool = true) {
        World.lockQueue.async(flags: .barrier) {
            if self.dispatchMode == .killScheduled || self.dispatchMode == .dead { return }
            assert(self.dispatchMode == .alive)

            let c = (call == nil) ? self.apoptosize : call!

            self.runningAsBarrier = runAsBarrier

            if runAsBarrier { c(); return }

            World.lockQueue.async { c() }
        }
    }

    func startTask(_ dispatchable: Dispatchable) {
        go({ dispatchable.go() }, runAsBarrier: true)
    }
}

extension Dispatch {
    func apoptosize() {

    }

    func colorize() {
        currentTask = Colorize(self)
        startTask(currentTask)
    }

    func shiftStart() {
        currentTask = Shift(self)
        startTask(currentTask)
    }

    func funge() {
        currentTask = Funge(self)
        startTask(currentTask)
    }

    func metabolize() {
        currentTask = Metabolize(self)
        startTask(currentTask)
    }
}
