import GameplayKit

extension Stepper {
    func arrive(completion: @escaping StepperDoubleCallback) {
//        print("p(\(core.selectoid.fishNumber))")
        let workItem = { [unowned self] in
//            print("q(\(self.core.selectoid.fishNumber))")
            assert(self.stepperIsEngaged2 == false)
            defer { self.stepperIsEngaged2 = false }
            self.stepperIsEngaged2 = true
            self.arrive_(completion: completion)
//            print("u(\(self.core.selectoid.fishNumber))")
        }

        Lockable<Void>().lock(workItem, { _ in
//            print("v(\(self.core.selectoid.fishNumber))")
        })
    }

    private func arrive_(completion: @escaping StepperDoubleCallback) {
//        print("r(\(core.selectoid.fishNumber))")
        getStartStopGridlets()
        touchFood(completion: completion)
        updateGridletContents()
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
//        print("A(\(self.core.selectoid.fishNumber))")
        if metabolism.mass > (victimStepper.metabolism.mass * 1.25) {
            self.stepperIsEngaged = false
//            print("B(\(self.core.selectoid.fishNumber))")
            return (self, victimStepper)
        } else {
            victimStepper.stepperIsEngaged = false
//            print("C(\(self.core.selectoid.fishNumber))")
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
        Lockable<Gridlet>().lock({ [unowned self] in
//            print("w(\(self.core.selectoid.fishNumber))")
            self.newGridlet!.contents = .arkon
            self.newGridlet!.sprite = self.sprite
            self.gridlet = self.newGridlet

            self.newGridlet = nil
            self.oldGridlet = nil
        }, { _ in
//            print("x(\(self.core.selectoid.fishNumber))")
            /* No completion callback */ })
    }
}
