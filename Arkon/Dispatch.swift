import Foundation

typealias GoCall = () -> Void

protocol Dispatchable {
    var scratch: Scratchpad? { get }
    var wiLaunch: DispatchWorkItem? { get }

    init(_ scratch: Scratchpad)
    func launch()
}

extension Dispatchable {
    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.serialQueue.async(execute: w)
    }
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
}

extension Dispatch {
    private func dispatch(_ type: Dispatchable.Type) {
        let lifelet = type.init(scratch)
        Grid.shared.serialQueue.async(execute: lifelet.launch)
    }

    func apoptosize()   { dispatch(Apoptosize.self) }

    func arrive()       { dispatch(Arrive.self) }

    func colorize()     { dispatch(Colorize.self) }

    func disengage()    { dispatch(Disengage.self) }

    func engage()       { dispatch(Engage.self) }

    func funge()        { dispatch(Funge.self) }

    func metabolize()   { dispatch(Metabolize.self) }

    func moveSprite()   { dispatch(MoveSprite.self) }

    func moveStepper()  { dispatch(MoveStepper.self) }

    func parasitize()   { dispatch(Parasitize.self) }

    func plot()         { dispatch(Plot.self) }

    func releaseStage() { dispatch(ReleaseStage.self) }

    func wangkhi()      { dispatch(WangkhiEmbryo.self) }
}
