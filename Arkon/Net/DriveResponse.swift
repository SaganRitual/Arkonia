import CoreGraphics

struct DriveResponse {

    enum MotorIndex: Int, CaseIterable { case jumpSelector, jumpSpeed }

    let net: Net
    let stepper: Stepper

    init(_ stepper: Stepper) {
        self.stepper = stepper
        self.net = stepper.net
    }

    func driveResponse(
        _ senseData: UnsafeMutablePointer<Float>,
        _ onComplete: @escaping (Bool) -> Void
    ) { net.driveSignal { self.driveResponse_B(senseData, onComplete) } }

    private func driveResponse_B(
        _ senseData: UnsafeMutablePointer<Float>,
        _ onComplete: @escaping (Bool) -> Void
    ) { MainDispatchQueue.async { self.driveResponse_C(senseData, onComplete) } }

    private func driveResponse_C(
        _ senseData: UnsafeMutablePointer<Float>,
        _ onComplete: @escaping (Bool) -> Void
    ) {
        Debug.log(level: 200) { "driveResponse_C.0 \(six(stepper.name))" }
        let cSensorPadCells = net.netStructure.sensorPadCCells

        // Divide the circle into cCellsWithinSenseRange slices
        let s0 = net.pMotorOutputs[MotorIndex.jumpSelector.rawValue]
        let s1 = s0 * Float(cSensorPadCells)
        let s2 = floor(s1)
        let s3 = Int(s2)

        // In case we get a 1.0 -- that would push us beyond the end of the array
        let targetOffset = (s3 == cSensorPadCells) ? cSensorPadCells - 1 : s3

        driveResponse_C1(senseData, targetOffset, onComplete)
    }

    private func driveResponse_C1(
        _ senseData: UnsafeMutablePointer<Float>,
        _ targetOffset: Int,
        _ onComplete: @escaping (Bool) -> Void
    ) {
        let jumpSpeedMotorOutput = stepper.net.pMotorOutputs[MotorIndex.jumpSpeed.rawValue]
        let onSuccess = { onComplete(true) }
        let onFailure = { onComplete(false) }

        if targetOffset > 0 {
            let targetAbsolute = stepper.sensorPad.thePadCells[targetOffset].gridAbsoluteIndex ?? -1
            Debug.log(level: 209) { "driveResponse_C1.0 \(six(stepper.name)) target is \(targetOffset) abs \(targetAbsolute)" }
            guard let correctedTarget = stepper.sensorPad.getFirstTargetableCell(
                startingAt: targetOffset
            ) else {
                Debug.log(level: 209) { "driveResponse_C1.1 \(six(stepper.name)) couldn't jump at all" }
                // If we couldn't find a cell to jump to (which would be a really
                // crowded situation), then just sit this one out
                onFailure(); return
            }

            let correctedTargetAbsolute = stepper.sensorPad.thePadCells[correctedTarget.padLocalIndex].gridAbsoluteIndex ?? -1
            Debug.log(level: 209) { "driveResponse_C1.2 \(six(stepper.name)) corrected target is \(correctedTarget.padLocalIndex) abs \(correctedTargetAbsolute)" }
            let from = stepper.sensorPad.thePadCells[0]
            let toLocalIx = correctedTarget.padLocalIndex
            let to = stepper.sensorPad.thePadCells[toLocalIx]

            let asPercentage = max(CGFloat(jumpSpeedMotorOutput), 0.1)

            stepper.jumpSpec = JumpSpec(from, to, asPercentage)

            // All done with most of the sensor pad. All we need now is the
            // shuttle; free up everything else for the other arkons
            stepper.sensorPad.pruneToShuttle(toLocalIx) {
                Debug.log(level: 207) { "driveResponse_C1.3 \(six(self.stepper.name))" }
                // If it fails, it doesn't come back, but goes on to apoptosize
                self.driveResponse_D(onSuccess)
            }

            return
        }

        Debug.log(level: 207) { "driveResponse_C1.4 \(six(stepper.name))" }
        onFailure()
    }

    private func driveResponse_D(_ onSuccess: @escaping () -> Void) {
        let isAlive = stepper.metabolism.applyJumpCosts(stepper.jumpSpec!)

        Debug.log(level: 207) { "driveResponse_D.0 \(six(stepper.name))" }
        if isAlive { onSuccess(); return }

        Debug.log(level: 207) { "driveResponse_D.1 \(six(stepper.name))" }
        stepper.apoptosize()
    }
}
