import Foundation

typealias GoCall = () -> Void

protocol DispatchableProtocol {
    init(_ scratch: Scratchpad)

    func launch()
}

class Dispatchable: DispatchableProtocol {
    var scratch: Scratchpad!

    required init(_ scratch: Scratchpad) { self.scratch = scratch }

    func launch() { fatalError() }
}

final class Dispatch {
    var lifelet: DispatchableProtocol!
    var name = ArkonName.empty
    var scratch: Scratchpad! = Scratchpad()
    var wiLaunch: DispatchWorkItem?

    init(_ stepper: Stepper? = nil) {
        scratch.dispatch = self
        scratch.stepper = stepper

        if let n = stepper?.name { self.name = n }
        self.scratch.name = self.name
    }

    init(parentNet: Net) {
        scratch.dispatch = self
        scratch.parentNet = parentNet
    }
}

extension Dispatch {
    static let dispatchQueue = DispatchQueue(
        label: "ak.dispatch.q", attributes: .concurrent, target: DispatchQueue.global()
    )

    private func dispatch(_ type: DispatchableProtocol.Type) {
        Dispatch.dispatchQueue.async {
            self.lifelet = type.init(self.scratch)
            self.lifelet.launch()
        }
    }

    func apoptosize()     { dispatch(Apoptosize.self) }

    func arrive()         { dispatch(Arrive.self) }

    func computeMove()    { dispatch(ComputeMove.self) }

    func disengage()      { dispatch(Disengage.self) }

    func engage()         { dispatch(Engage.self) }

    func moveSprite()     { dispatch(MoveSprite.self) }

    func moveStepper()    { dispatch(MoveStepper.self) }

    func parasitize()     { dispatch(Parasitize.self) }

    func releaseShuttle() { dispatch(ReleaseShuttle.self) }

    func spawn()          { dispatch(Spawn.self) }

    func tickLife()       { dispatch(TickLife.self) }
}
