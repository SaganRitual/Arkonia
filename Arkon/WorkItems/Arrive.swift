import GameplayKit

typealias LockStepper = Dispatch.Lockable<Stepper>

extension Stepper {
    func arrive(onComplete: @escaping LockStepper.LockOnComplete) {
        print("P(\(core.selectoid.fishNumber))")
        func workItem() -> [Stepper]? {
            print("U(\(self.core.selectoid.fishNumber))")
            arrive_(onComplete: onComplete)
            print("u(\(self.core.selectoid.fishNumber))")
            return nil
        }

        print("p(\(self.core.selectoid.fishNumber))")
        Grid.lock(workItem, nil, .concurrent)
    }

    private func arrive_(
        onComplete: @escaping LockStepper.LockOnComplete
    ) {
        print("r(\(core.selectoid.fishNumber))")
        getStartStopGridlets()

                func overhead(_ combatants: [Stepper]?) {
                    print("oh1", terminator: "")
                    updateGridletContents()
                    print("oh2", terminator: "")
                    onComplete(combatants)
                    print("oh3", terminator: "")
                }

        touchFood(onComplete: overhead)
//        print("s(\(core.selectoid.fishNumber))")
    }

    private func eatManna(_ manna: Manna) {
        let harvested = manna.harvest()
        metabolism.absorbEnergy(harvested)
        metabolism.inhale()
        MannaCoordinator.shared.beEaten(manna.sprite)
    }

    private func getStartStopGridlets() {
        gridlet.sprite = nil
        gridlet.contents = .nothing
        gridlet.gridletIsEngaged = false
        oldGridlet = gridlet

        let newGridPosition = gridlet.gridPosition + shiftTarget
        newGridlet = Gridlet.at(newGridPosition)
//        print("st1 = \(shiftTarget) - \(newGridPosition)")
    }

    private func touchArkon(_ victimStepper: Stepper) -> (Stepper, Stepper) {
        if metabolism.mass > (victimStepper.metabolism.mass * 1.25) {
            return (self, victimStepper)
        } else {
            return (victimStepper, self)
        }
    }

    private func touchFood(
        onComplete: @escaping LockStepper.LockOnComplete
    ) {
        print("touchFood")
        guard let foodLocation = newGridlet else { fatalError() }

        var userDataKey = SpriteUserDataKey.karamba

        switch newGridlet?.contents {
        case .arkon:
            userDataKey = .stepper

            if let otherSprite = foodLocation.sprite,
                let otherUserData = otherSprite.userData,
                let otherAny = otherUserData[userDataKey],
                let otherStepper = otherAny as? Stepper
            {
                let (parasite, victim) = touchArkon(otherStepper)
                assert(parasite.core.selectoid.fishNumber != victim.core.selectoid.fishNumber)
                onComplete([parasite, victim])
                return
            }

        case .manna:
            userDataKey = .manna

            if let otherSprite = foodLocation.sprite,
                let otherUserData = otherSprite.userData,
                let otherAny = otherUserData[userDataKey],
                let manna = otherAny as? Manna
            {
                eatManna(manna)
                onComplete(nil)
                return
            }

        case .nothing:
            onComplete(nil)
            return

        case nil:
            break
        }

        fatalError()
    }

    private func updateGridletContents() {
//        print("t(\(self.core.selectoid.fishNumber))")
        Grid.lock({ [weak self] () -> [Void]? in
            guard let myself = self else {
//                print("Bail in updateGridletContents")
                return nil
            }

            guard let ng = myself.newGridlet else {
//                print("Bail-ng in updateGridletContents")
                return nil
            }

//            print("w(\(self.core.selectoid.fishNumber))")
            ng.contents = .arkon
            ng.sprite = myself.sprite
            myself.gridlet = ng

            myself.newGridlet = nil
            myself.oldGridlet = nil

            return nil
        })
    }
}
