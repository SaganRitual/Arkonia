import GameplayKit

extension Stepper {
    func arrive(completion: @escaping StepperDoubleCallback) {
        let workItem = { [unowned self] in
            assert(self.stepperIsEngaged2 == false)
            defer { self.stepperIsEngaged2 = false }
            self.stepperIsEngaged2 = true
            self.arrive_(completion: completion)
        }

        workItem()
//        syncQueue.async(flags: .barrier, execute: workItem)
    }

    private func arrive_(completion: @escaping StepperDoubleCallback) {
        getStartStopGridlets()
        touchFood(completion: completion)
        updateGridletContents()
    }

    private func eatManna(_ manna: Manna) {
        let sprite = manna.sprite

        let harvested = sprite.manna.harvest()
        metabolism.absorbEnergy(harvested)
        metabolism.inhale()
        manna.beEaten()
    }

    private func getStartStopGridlets() {
        gridlet.sprite = nil
        gridlet.contents = .nothing
        oldGridlet = gridlet

        let newGridPosition = gridlet.gridPosition + shiftTarget
        newGridlet = Gridlet.at(newGridPosition)
    }

    private func touchArkon(_ victimStepper: Stepper) -> (Stepper, Stepper) {
        if metabolism.mass > (victimStepper.metabolism.mass * 1.25) {
            self.stepperIsEngaged = false
            return (self, victimStepper)
        } else {
            victimStepper.stepperIsEngaged = false
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
                completion(parasite, victim)
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
            }

        case .nothing:
            completion(nil, nil)

        case nil:      fatalError()
        }

    }

    private func updateGridletContents() {
        let newGridPosition = gridlet.gridPosition + shiftTarget
        gridlet = Gridlet.at(newGridPosition)

        gridlet.contents = .arkon
        gridlet.sprite = sprite
    }
}
