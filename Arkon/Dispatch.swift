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
        case is Arrive: return "Arrive"
        case is Colorize: return "Colorize"
        case is Disengage: return "Disengage"
        case is Engage: return "Engage"
        case is Funge: return "Funge"
        case is Metabolize: return "Metabolize"
        case is MoveSprite: return "MoveSprite"
        case is MoveStepper: return "MoveStepper"
        case is Parasitize: return "Parasitize"
        case is Plot: return "Plot"
        case is ReleaseStage: return "ReleaseStage"
        case is WangkhiEmbryo: return "WangkhiEmbryo"
        case nil: return "Nothing"
        default: fatalError()
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
}

extension Dispatch {
    private func notify(_ notifiee: DispatchWorkItem?, lifelet: Dispatchable) {
        Log.L.write("notify: \(getTaskName(lifelet))")
        guard let n = notifiee else { fatalError() }
        n.notify(queue: concurrentQueue, execute: lifelet.launch)
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

    func disengage(_ notifiee: DispatchWorkItem?) {
        notify(notifiee, lifelet: Disengage(scratch))
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
        Log.L.write("run engage")
        concurrentQueue.async(execute: lifelet.launch)
    }

    func moveStepper() {
        let lifelet = MoveStepper(scratch)
        Log.L.write("run moveStepper")
        concurrentQueue.async(execute: lifelet.launch)
    }

    func wangkhi() {
        let lifelet = WangkhiEmbryo(scratch)
        Log.L.write("run wangkhi")
        concurrentQueue.async(execute: lifelet.launch)
    }
}
