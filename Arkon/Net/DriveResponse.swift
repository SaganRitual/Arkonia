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
            var toCell: IngridCell?
            var finalTargetLocalIx: Int?
            var virtualScenePosition: CGPoint?

            for ss_ in 0..<cSensorPadCells where toCell == nil {
                let ss = (ss_ + targetOffset) % cSensorPadCells

                // If the target cell isn't available (meaning we couldn't
                // see it when we tried to lock it, because someone had that
                // cell locked already), then find the first visible cell after
                // our target. If that turns out to be the cell I'm sitting in,
                // skip it and look for the next after that. I've decided to
                // jump already, so, I'll jump.
                //
                // No particular reason for this policy. We could just as easily
                // stay here. Maybe put it under genetic control and see if it
                // has any effect
                if ss == 0 { continue }

                // If we don't get a core cell, it's because we don't have the
                // cell locked (someone else has it), so we can't jump there
                guard let coreCell = stepper.sensorPad[ss].coreCell else { continue }

                // Of course, don't forget that we can't squeeze into the
                // same cell as another arkon, at least not for now
                let contents = Ingrid.shared.getContents(in: coreCell)
                if contents == .empty || contents == .manna {
                    finalTargetLocalIx = ss
                    toCell = coreCell
                    virtualScenePosition = stepper.sensorPad[ss].virtualScenePosition
                }
            }

            guard let tc = toCell, let lix = finalTargetLocalIx else { // We're surrounded!
                Debug.log(level: 199) { "Arkon \(stepper.name) couldn't jump out of \(stepper.ingridCellAbsoluteIndex)" }
                onComplete(); return
            }

            Debug.log(level: 195) { "move \(stepper.name) with \(s0) to local ix \(lix) abs ix \(tc.absoluteIndex)" }

            let fc = stepper.sensorPad[0].coreCell!
            let asPercentage = max(CGFloat(jumpSpeedMotorOutput), 0.1)

            stepper.jumpSpec = JumpSpec(fc, tc, virtualScenePosition, asPercentage)

            let isAlive = stepper.metabolism.applyJumpCosts(stepper.jumpSpec!)

            if !isAlive { stepper.dispatch!.apoptosize(); return }
        }

        onComplete()
    }
}
