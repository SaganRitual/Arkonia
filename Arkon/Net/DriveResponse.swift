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

        let jumpSpeedMotorOutput = stepper.net.pMotorOutputs[MotorIndex.jumpSpeed.rawValue]

        if targetOffset > 0 {
            guard let correctedTarget = stepper.sensorPad.getCorrectedTarget(
                candidateLocalIndex: targetOffset
            ) else {
                Debug.log(level: 200) { "driveResponse_C.1 \(six(stepper.name))" }
                let okToJump = false
                onComplete(okToJump); return
            }

            Debug.log(level: 200) { "driveResponse_C.2 \(six(stepper.name))" }
            let from = stepper.sensorPad.thePad[0]!.coreCell!
            let toLocalIx = correctedTarget.finalTargetLocalIx
            let to = correctedTarget.toCell
            let virtual = correctedTarget.virtualScenePosition

            let asPercentage = max(CGFloat(jumpSpeedMotorOutput), 0.1)

            stepper.jumpSpec = JumpSpec(from, to, toLocalIx, virtual, asPercentage)

            // All done with most of the sensor pad. All we need now is the
            // shuttle; free up everything else for the other arkons
            stepper.sensorPad.pruneToShuttle(toLocalIx)
            driveResponse_D(onComplete)
            return
        }

        Debug.log(level: 200) { "driveResponse_C.3 \(six(stepper.name))" }
        let okToJump = false
        onComplete(okToJump)
    }

    private func driveResponse_D(_ onComplete: @escaping (Bool) -> Void) {
        let isAlive = stepper.metabolism.applyJumpCosts(stepper.jumpSpec!)

        Debug.log(level: 200) { "driveResponse_D.0 \(six(stepper.name))" }
        if isAlive { let okToJump = true; onComplete(okToJump); return }

        Debug.log(level: 200) { "driveResponse_D.1 \(six(stepper.name))" }
        stepper.dispatch.apoptosize()
    }
}
