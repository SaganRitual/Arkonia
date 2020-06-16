import CoreGraphics
import Dispatch

final class DriveNetSignal: Dispatchable {
    let response: DriveResponse
    let stimulus: DriveStimulus

    required init(_ stepper: Stepper?) {
        stimulus = DriveStimulus(stepper!)
        response = DriveResponse(stepper!)
        super.init(stepper!)
    }

    internal override func launch() { driveNetSignal_A() }

    private func driveNetSignal_A() {
        stimulus.driveStimulus(driveNetSignal_B)
    }

    private func driveNetSignal_B() {
        let pNeurons = UnsafeMutablePointer(mutating: stepper.net!.pNeurons)
        response.driveResponse(pNeurons, driveNetSignal_C)
    }

    private func driveNetSignal_C(_ didJump: Bool) {
        if didJump { stepper.dispatch!.moveSprite(); return }

        stepper.dispatch!.disengageGrid()
    }
}
