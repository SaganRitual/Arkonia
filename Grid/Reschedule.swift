import Foundation

extension GridCell {
    func descheduleIf(_ stepper: Stepper, _ catchDumbMistakes: DispatchQueueID) {
        assert(catchDumbMistakes == .arkonsPlane)

        toReschedule.removeAll { waitingStepper in
            let remove = waitingStepper.name == stepper.name
            Debug.log(level: 169) { "deschedule \(six(stepper.name)) == \(six(waitingStepper.name))" }
            return remove
        }
    }

    func getRescheduledArkon(_ catchDumbMistakes: DispatchQueueID) -> Stepper? {
        assert(catchDumbMistakes == .arkonsPlane)

        #if DEBUG
        if !toReschedule.isEmpty {
            Debug.log(level: 168) {
                "getRescheduledArkon \(six(toReschedule.first!.name)) " +
                "\(toReschedule.count)"
            }
        }
        #endif

        defer { if toReschedule.isEmpty == false { _ = toReschedule.removeFirst() } }
        return toReschedule.first
    }

    func reengageRequesters(_ catchDumbMistakes: DispatchQueueID) {
        assert(catchDumbMistakes == .arkonsPlane)

        Debug.log(level: 169) {
            return self.toReschedule.isEmpty ? nil :
            "Reengage from \(self.toReschedule.map { $0.name }) at \(gridPosition)"
        }

        // Re-launch all rescheduled arkons before re-launching the manna
        while let waitingStepper = self.getRescheduledArkon(catchDumbMistakes) {
            if let dispatch = waitingStepper.dispatch {
                let scratch = dispatch.scratch
                assert(scratch!.engagerKey == nil)
                Debug.log(level: 169) { "reengageRequesters; disengage \(waitingStepper.name) at \(self.gridPosition)" }
                dispatch.disengage()
                return
            }

            Debug.log(level: 1698) { "reengageRequesters; no dispatch for \(waitingStepper.name) at \(self.gridPosition)" }
        }

        if self.mannaAwaitingRebloom {
            Debug.log(level: 168) { "reengageRequesters/rebloom manna at \(self.gridPosition)" }

            self.manna!.rebloom()
            self.mannaAwaitingRebloom = false
        }
    }

    func reschedule(_ stepper: Stepper, _ catchDumbMistakes: DispatchQueueID) {
        #if true
        precondition(
            catchDumbMistakes == .arkonsPlane,
            "Dumb mistake -- line \(#line) in \(#file)"
        )

        precondition(
            self.isLocked && self.ownerName != .empty && self.ownerName != stepper.name,
            "We shouldn't be here unless the lock attempt failed -- line \(#line) in \(#file)"
        )

        // The same arkon shouldn't be in here twice
        precondition(
            toReschedule.contains { $0.name == stepper.name } == false,
            "The same arkon shouldn't be in here twice -- line \(#line) in \(#file)"
        )

        Debug.log(level: 182) {
            "Reschedule \(self.stepper!.name)"
            + " for cell \(self.gridPosition)"
            + " owned by \(self.ownerName)"
        }

        Grid.arkonsPlaneQueue.asyncAfter(deadline: .now() + TimeInterval(1)) { self.debugFoo() }

        Debug.debugColor(stepper, .brown, .cyan)
        #endif

        toReschedule.append(stepper)
        stepper.dispatch.scratch.isRescheduled = true   // Debug
    }

    func debugFoo() {
        if !self.toReschedule.isEmpty {
            Debug.log(level: 183) {
                "Still here:"
                + " reschedule \(self.stepper!.name)"
                + " for cell \(self.gridPosition)"
                + " owned by \(self.ownerName)"
            }
            Grid.arkonsPlaneQueue.asyncAfter(deadline: .now() + TimeInterval(1)) { self.debugFoo() }
        }
    }
}
