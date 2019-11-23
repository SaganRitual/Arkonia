import Foundation

typealias GoCall = () -> Void

protocol Dispatchable {
    var scratch: Scratchpad? { get }
    var wiLaunch: DispatchWorkItem? { get }

    func launch()
}

extension Dispatchable { }

class Scratchpad {
    var isAwaitingWakeup = false
    var canSpawn = false
    var battle: (Stepper, Stepper)?
    weak var dispatch: Dispatch?
    var gridCell: GridCell?
    var gridCellConnector: SafeConnectorProtocol? {
        willSet {
            let t: String
            switch newValue {
            case is SafeCell: t = "SafeCell"
            case is SafeSenseGrid: t = "SafeSenseGrid"
            case is SafeStage: t = "SafeStage"
            case nil: t = "nothing"
            default: fatalError()
            }
            Log.L.write("gcc reset \(t) for \(six(stepper?.name))")
        }
    }
    var isAlive = false
    var isApoptosizing = false
    var launched = false
    weak var stepper: Stepper?
    var worldStats: World.StatsCopy?

    var safeCell:  SafeCell { return (gridCellConnector as? SafeCell)! }
    var senseGrid: SafeSenseGrid { return (gridCellConnector as? SafeSenseGrid)! }
    var stage:     SafeStage { return (gridCellConnector as? SafeStage)! }

    //swiftlint:disable large_tuple
    func getKeypoints() -> (Scratchpad, Dispatch, Stepper) {
        guard let dp = dispatch, let st = stepper else { fatalError() }
        return (self, dp, st)
    }
    //swiftlint:enable large_tuple
}

final class Dispatch {
    func getTaskName(_ task: Dispatchable?) -> String {
        switch task {
        case is Apoptosize: return "Apoptosize"
        case is Colorize: return "Colorize"
        case is Funge: return "Funge"
        case is Metabolize: return "Metabolize"
        case is Parasitize: return "Parasitize"
        case is WangkhiEmbryo: return "WangkhiEmbryo"
        case nil: return "Nothing"
        default: fatalError()
        }
    }

    var currentTask: Dispatchable! {
        willSet {
            let taskName = getTaskName(newValue)
            Log.L.write("switching to \(taskName) \(six(newValue?.scratch?.stepper?.name))")
        }

        didSet {
            let taskName = getTaskName(oldValue)
            Log.L.write("ending \(taskName) \(six(oldValue?.scratch?.stepper?.name))")
        }
    }

    var scratch = Scratchpad()

    init(_ stepper: Stepper? = nil) {
        scratch.dispatch = self
        scratch.stepper = stepper
    }

    let concurrentQueue = DispatchQueue(
        label: "arkonia.open.concurrent",
        attributes: .concurrent,
        target: DispatchQueue.global()
    )

    let taskSyncQueue = DispatchQueue(
        label: "arkonia.task.serial",
        attributes: [],
        target: DispatchQueue.global(qos: .userInitiated)
    )

    func go(_ newTask: Dispatchable, getSync: Bool = true) {
        let f: () -> Void = {
            guard self.currentTask == nil else { fatalError() }
            self.currentTask = newTask
            self.currentTask.launch()
        }

        if getSync { taskSyncQueue.sync(execute: f); return }

        f()
    }
}

extension Dispatch {
    private func notify(_ notifiee: DispatchWorkItem?, lifelet: Dispatchable) {
        guard let n = notifiee else { fatalError() }
        n.notify(queue: concurrentQueue, execute: lifelet.wiLaunch!)
    }

    func apoptosize(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: Apoptosize(scratch))
    }

    func arrive(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: Arrive(scratch))
    }

    func colorize(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: Colorize(scratch))
    }

    func engage(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: Engage(scratch))
    }

    func metabolize(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: Metabolize(scratch))
    }

    func moveSprite(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: MoveSprite(scratch))
    }

    func moveStepper(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: MoveStepper(scratch))
    }

    func parasitize(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: Parasitize(scratch))
    }

    func plot(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: Plot(scratch))
    }

    func releaseStage(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: ReleaseStage(scratch))
    }

    func wangkhi(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: WangkhiEmbryo(scratch))
    }
}

extension Dispatch {
    func engage() {
        let lifelet = Engage(scratch)
        concurrentQueue.async(execute: lifelet.wiLaunch!)
    }

    func disengage() {
        let lifelet = Disengage(scratch)
        concurrentQueue.async(execute: lifelet.wiLaunch!)
    }

    func moveStepper() {
        let lifelet = MoveStepper(scratch)
        concurrentQueue.sync(execute: lifelet.wiLaunch!)
    }

    func wangkhi() {
        let lifelet = WangkhiEmbryo(scratch)
        concurrentQueue.async(execute: lifelet.wiLaunch!)
    }
}
