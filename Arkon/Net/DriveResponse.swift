import CoreGraphics

struct DriveResponse {

    struct CorrectedTarget {
        let toCell: IngridCell
        let finalTargetLocalIx: Int
        let virtualScenePosition: CGPoint?
    }

    enum MotorIndex: Int, CaseIterable { case jumpSelector, jumpSpeed }

    let net: Net
    let stepper: Stepper

    init(_ stepper: Stepper) {
        self.stepper = stepper
        self.net = stepper.net!
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
            guard let correctedTarget = correctForUnreachableTarget(targetOffset) else {
                Debug.log(level: 199) { "Arkon \(stepper.name) couldn't jump out of \(stepper.ingridCellAbsoluteIndex)" }

                let okToJump = false
                onComplete(okToJump); return
            }

            Debug.log(level: 198) {
                "move \(stepper.name)"
                + " with \(s0)"
                + " to local ix \(correctedTarget.finalTargetLocalIx)"
                + " abs ix \(correctedTarget.toCell.absoluteIndex)"
            }

            let from = stepper.sensorPad.thePad[0].coreCell!
            let fromLocalIx = correctedTarget.finalTargetLocalIx
            let to = correctedTarget.toCell
            let virtual = correctedTarget.virtualScenePosition

            let asPercentage = max(CGFloat(jumpSpeedMotorOutput), 0.1)

            stepper.jumpSpec = JumpSpec(from, fromLocalIx, to, virtual, asPercentage)

            Ingrid.shared.disengageSensorPad(
                stepper.sensorPad, padCCells: cSensorPadCells
            ) { self.driveResponse_D(onComplete) }

            return
        }

        let okToJump = false
        onComplete(okToJump)
    }

    private func driveResponse_D(_ onComplete: @escaping (Bool) -> Void) {
        let isAlive = stepper.metabolism.applyJumpCosts(stepper.jumpSpec!)

        if isAlive { let okToJump = true; onComplete(okToJump); return }

        stepper.dispatch!.apoptosize()
    }

    private func correctForUnreachableTarget(_ targetOffset: Int) -> CorrectedTarget? {
        let cSensorPadCells = net.netStructure.sensorPadCCells

        var toCell: IngridCell?
        var finalTargetLocalIx: Int?
        var virtualScenePosition: CGPoint?

        Debug.log(level: 198) { "correctForUnreachableTarget.0 try \(targetOffset)" }

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
            if ss == 0 {
                Debug.log(level: 198) { "correctForUnreachableTarget.1 skipping pad[0] \(targetOffset)" }
                continue
            }

            // If we don't get a core cell, it's because we don't have the
            // cell locked (someone else has it), so we can't jump there
            guard let coreCell = stepper.sensorPad.thePad[ss].coreCell else {
                Debug.log(level: 198) { "correctForUnreachableTarget.2 no lock at \(ss)" }
                continue
            }

            // Of course, don't forget that we can't squeeze into the
            // same cell as another arkon, at least not for now
            let contents = Ingrid.shared.getContents(in: coreCell)
            if contents == .empty || contents == .manna {
                finalTargetLocalIx = ss
                toCell = coreCell
                virtualScenePosition = stepper.sensorPad.thePad[ss].virtualScenePosition
                break
            }
        }

        return toCell == nil ? nil :
            CorrectedTarget(
                toCell: toCell!, finalTargetLocalIx: finalTargetLocalIx!,
                virtualScenePosition: virtualScenePosition
            )
    }
}
