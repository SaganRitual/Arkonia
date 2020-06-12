import Foundation

extension Stepper {
    func driveNetSignal() {
        func driveNetSignal_A() {
            Debug.debugColor(self, .blue, .red)

            let stimulus = DriveStimulus(self)
            stimulus.driveStimulus(driveNetSignal_B)
        }

        func driveNetSignal_B() {
            let pNeurons = UnsafeMutablePointer(mutating: net.pNeurons)
            let response = DriveResponse(self)
            response.driveResponse(pNeurons, driveNetSignal_C)
        }

        func driveNetSignal_C(_ netResultIsJump: Bool) {
            if netResultIsJump { moveSprite() } else { disengageGrid() }
        }

        MainDispatchQueue.async(execute: driveNetSignal_A)
    }
}
