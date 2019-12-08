import Foundation

typealias GoCall = () -> Void

protocol DispatchableProtocol {
    init(_ scratch: Scratchpad)

    func launch()
}

class Dispatchable: DispatchableProtocol {
    var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    required init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem { [weak self] in self?.launch_() }
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.serialQueue.async(execute: w)
    }

    func launch_() { preconditionFailure() }
}

final class Dispatch {
    func getTaskName(_ task: DispatchableProtocol?) -> String {
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
        case is Larva: return "Larva"
        case nil: return "Nothing"
        default: fatalError()
        }
    }

    var lifelet: DispatchableProtocol!
    var scratch = Scratchpad()
    var wiLaunch: DispatchWorkItem?

    init(_ stepper: Stepper? = nil) {
        scratch.dispatch = self
        scratch.stepper = stepper
    }

    init(parentNet: Net) {
        scratch.dispatch = self
        scratch.parentNet = parentNet
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.serialQueue.async(execute: w)
    }
}

extension Dispatch {
    private func dispatch(_ type: DispatchableProtocol.Type) {
        if type is Apoptosize.Type {
            precondition(scratch.isApoptosizing == false)
        }

        if scratch.isApoptosizing { return }

        lifelet = type.init(scratch)
        lifelet.launch()
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

    func spawn()        { dispatch(Larva.self) }
}
