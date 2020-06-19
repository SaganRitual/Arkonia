import Foundation

typealias GoCall = () -> Void

protocol DispatchableProtocol {
    init(_ stepper: Stepper?)

    func launch()
}

class Dispatchable: DispatchableProtocol {
    var stepper: Stepper!

    required init(_ stepper: Stepper?) { self.stepper = stepper }

    func launch() { fatalError() }
}

final class Dispatch {
    var lifelet: DispatchableProtocol!
    weak var stepper: Stepper?

    init(_ stepper: Stepper? = nil) {
        if let st = stepper {
            self.stepper = st
            st.dispatch = self
        }
    }
}

let MainDispatchQueue = DispatchQueue(
    label: "ak.dispatch.q", attributes: .concurrent, target: DispatchQueue.global()
)

extension Dispatch {
    private func dispatch(_ type: DispatchableProtocol.Type) {
        func dispatch_() {
            lifelet = type.init(stepper)
            lifelet.launch()
        }

        if Arkonia.debugGrid {
            MainDispatchQueue.asyncAfter(deadline: .now() + 1, execute: dispatch_)
        } else {
            MainDispatchQueue.async(execute: dispatch_)
        }
    }

    func apoptosize()     { dispatch(Apoptosize.self) }

    func arrive()         { dispatch(Arrive.self) }

    func driveNetSignal() { dispatch(DriveNetSignal.self) }

    func disengageGrid()  { dispatch(DisengageGrid.self) }

    func engageGrid()     { dispatch(EngageGrid.self) }

    func moveSprite()     { dispatch(MoveSprite.self) }

    func moveStepper()    { dispatch(MoveStepper.self) }

    func spawn()          { dispatch(Spawn.self) }

    func tickLife()       { dispatch(TickLife.self) }
}
