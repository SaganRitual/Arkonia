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
        let cSensorPadCells = net.netStructure.cCellsWithinSenseRange

        // Divide the circle into cCellsWithinSenseRange slices
        let s0 = net.pMotorOutputs[MotorIndex.jumpSelector.rawValue]
        let s1 = s0 * Float(cSensorPadCells)
        let s2 = floor(s1)
        let s3 = Int(s2)

        // In case we get a 1.0 -- that would push us beyond the end of the array
        let targetOffset = (s3 == cSensorPadCells) ? cSensorPadCells - 1 : s3

        let jumpSpeedMotorOutput = stepper.net.pMotorOutputs[MotorIndex.jumpSpeed.rawValue]

        if targetOffset > 0 {
            var toCell = stepper.sensorPad[targetOffset]

            for ss_ in 0..<cSensorPadCells {
                let ss = (ss_ + targetOffset) % cSensorPadCells
                if toCell.cell != nil { break }

                toCell = stepper.sensorPad[ss]
            }

            hardAssert(toCell.cell != nil) { "No cells available to jump to?" }

            Debug.log(level: 195) { "move \(stepper.name) with \(s0) to local ix \(targetOffset) abs ix \(toCell.absoluteIndex)" }

            let fromCell = stepper.sensorPad[0]
            let asPercentage = max(CGFloat(jumpSpeedMotorOutput), 0.1)

            stepper.jumpSpec = JumpSpec(fromCell, toCell, asPercentage)

            let isAlive = stepper.metabolism.applyJumpCosts(stepper.jumpSpec!)

            if !isAlive { stepper.dispatch!.apoptosize(); return }
        }

        onComplete()
    }
}
