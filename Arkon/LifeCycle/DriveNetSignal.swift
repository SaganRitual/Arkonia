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
        let log = (0..<stepper.net.netStructure.cSenseNeurons).map { pNeurons[$0] }
        Debug.log(level: 193) { "drive net signal, senseLayer in = \(log)" }
        response.driveResponse(pNeurons, driveNetSignal_C)
    }

    private func driveNetSignal_C() {
        if stepper.jumpSpec == nil { stepper.dispatch!.disengageGrid() }
        else                       { stepper.dispatch!.moveSprite() }
    }
}
