import GameplayKit

extension Stepper {
    func arrive(completion: @escaping StepperDoubleCallback) {
//        print("p(\(core.selectoid.fishNumber))")
        let workItem = { [weak self] in
            self?.arrive_(completion: completion)
//            print("u(\(self.core.selectoid.fishNumber))")
        }

        Lockable<Void>().lock(workItem, { _ in
//            print("v(\(self.core.selectoid.fishNumber))")
        })
    }

    private func arrive_(completion: @escaping StepperDoubleCallback) {
//        print("r(\(core.selectoid.fishNumber))")
        getStartStopGridlets()

                func overhead(_ parasite: Stepper?, _ victim: Stepper?) {
//                    print("oh1", terminator: "")
                    updateGridletContents()
//                    print("oh2", terminator: "")
                    completion(parasite, victim)
//                    print("oh3", terminator: "")
                }

        touchFood(completion: overhead)
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

    private func touchFood(completion: @escaping StepperDoubleCallback) {
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
                completion(parasite, victim)
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
                completion(nil, nil)
                return
            }

        case .nothing:
            completion(nil, nil)
            return

        case nil:
            break
        }

        fatalError()
    }

    private func updateGridletContents() {
//        print("t(\(self.core.selectoid.fishNumber))")
        Lockable<Gridlet>().lock({ [weak self] in
            guard let myself = self else {
//                print("Bail in updateGridletContents")
                return
            }

            guard let ng = myself.newGridlet else {
//                print("Bail-ng in updateGridletContents")
                return
            }

//            print("w(\(self.core.selectoid.fishNumber))")
            ng.contents = .arkon
            ng.sprite = myself.sprite
            myself.gridlet = ng

            myself.newGridlet = nil
            myself.oldGridlet = nil
        }, { _ in
//            print("x(\(self.core.selectoid.fishNumber))")
            /* No completion callback */ })
    }
}
