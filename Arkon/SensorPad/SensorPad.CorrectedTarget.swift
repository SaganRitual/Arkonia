import Foundation

extension SensorPad {

    struct CorrectedTarget {
        let toCell: IngridCell
        let finalTargetLocalIx: Int
        let virtualScenePosition: CGPoint?
    }

    func getCorrectedTarget(candidateLocalIndex targetOffset: Int) -> CorrectedTarget? {
        var toCell: IngridCell?
        var finalTargetLocalIx: Int?
        var virtualScenePosition: CGPoint?

        Debug.log(level: 198) { "getCorrectedTarget.0 try \(targetOffset)" }

        for ss_ in 0..<cCells {
            let ss = (ss_ + targetOffset) % cCells
            let absoluteIndex = thePad[ss]!.absoluteIndex

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
            if ss == cCells - 1 {
                Debug.log(level: 198) { "getCorrectedTarget.1 skipping pad[0] at \(ss) (local \(absoluteIndex))" }
                continue
            }

            // If we don't get a core cell, it's because we don't have the
            // cell locked (someone else has it), so we can't jump there
            guard let coreCell = thePad[ss]!.coreCell else {
                Debug.log(level: 198) { "getCorrectedTarget.2 no lock at \(ss) (local \(absoluteIndex))" }
                continue
            }

            // Of course, don't forget that we can't squeeze into the
            // same cell as another arkon, at least not for now
            let contents = Ingrid.shared.getContents(in: coreCell)
            if contents == .empty || contents == .manna {
                finalTargetLocalIx = ss
                toCell = coreCell
                virtualScenePosition = thePad[ss]!.virtualScenePosition
                break   // We have the cell we want
            }
        }

        guard let t = toCell else {
            Debug.log(level: 198) { "getCorrectedTarget.3 tried \(targetOffset), nothing available" }
            return nil
        }

        Debug.log(level: 198) { "getCorrectedTarget.4 tried \(targetOffset) got \(finalTargetLocalIx!)" }

        return CorrectedTarget(
            toCell: t, finalTargetLocalIx: finalTargetLocalIx!,
            virtualScenePosition: virtualScenePosition
        )
    }

}