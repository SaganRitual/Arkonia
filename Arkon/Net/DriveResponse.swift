import CoreGraphics

struct DriveResponse {

    enum MotorIndex: Int, CaseIterable { case jumpSelector, jumpSpeed }

    let net: Net
    let stepper: Stepper

    init(_ stepper: Stepper) {
        self.stepper = stepper
        self.net = stepper.net!
    }

    func driveResponse(
        _ senseData: UnsafeMutablePointer<Float>,
        _ onComplete: @escaping () -> Void
    ) { net.driveSignal { self.driveResponse_B(senseData, onComplete) } }

    private func driveResponse_B(
        _ senseData: UnsafeMutablePointer<Float>,
        _ onComplete: @escaping () -> Void
    ) { Dispatch.dispatchQueue.async { self.driveResponse_C(senseData, onComplete) } }

    private func driveResponse_C(
        _ senseData: UnsafeMutablePointer<Float>,
        _ onComplete: @escaping () -> Void
    ) {
        // Divide the circle into cCellsWithinSenseRange slices
        let s0 = net.pMotorOutputs[MotorIndex.jumpSelector.rawValue]
        let s1 = s0 * Float(net.netStructure.cCellsWithinSenseRange)
        let s2 = floor(s1)
        let s3 = Int(s2)
        let targetOffset = s3

        let jumpSpeedMotorOutput = stepper.net.pMotorOutputs[MotorIndex.jumpSpeed.rawValue]

        if targetOffset > 0 {
            Debug.log(level: 194) { "move with \(s0) to local ix \(targetOffset)" }

            let fromCell = stepper.sensorPad[0]
            let toCell = stepper.sensorPad[targetOffset]
            let asPercentage = max(CGFloat(jumpSpeedMotorOutput), 0.1)

            stepper.jumpSpec = JumpSpec(fromCell, toCell, asPercentage)

            let isAlive = stepper.metabolism.applyJumpCosts(stepper.jumpSpec)

            if !isAlive {
                Debug.log(level: 192) { "driveResponse_C -> apoptosize" }
                stepper.dispatch!.apoptosize()
                return
            }
        }

        onComplete()
    }
}
