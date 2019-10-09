import GameplayKit

extension Stepper {
    func arrive() {
        getStartStopGridlets()
        touchFood()
        updateGridletContents()
    }

    func eatManna(_ manna: Manna) {
        let sprite = manna.sprite

        let harvested = sprite.manna.harvest()
        metabolism.absorbEnergy(harvested)
        metabolism.inhale()
        manna.beEaten()
    }

    func getStartStopGridlets() {
        gridlet.sprite = nil
        gridlet.contents = .nothing
        oldGridlet = gridlet

        let newGridPosition = gridlet.gridPosition + shiftTarget
        newGridlet = Gridlet.at(newGridPosition)
    }

    func touchArkon(_ victimStepper: Stepper) {
        if metabolism.mass > (victimStepper.metabolism.mass * 1.25) {
            victimStepper.coordinator.dispatch(.beParasitized)
            coordinator.dispatch(.parasitize)
        } else {
            victimStepper.coordinator.dispatch(.parasitize)
            coordinator.dispatch(.beParasitized)
        }
    }

    func touchFood() {
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
                touchArkon(otherStepper)
            }

        case .manna:
            userDataKey = .manna

            if let otherSprite = foodLocation.sprite,
                let otherUserData = otherSprite.userData,
                let otherAny = otherUserData[userDataKey],
                let manna = otherAny as? Manna
            {
                eatManna(manna)
            }

        case .nothing: break
        case nil:      fatalError()
        }

    }

    func updateGridletContents() {
        let newGridPosition = gridlet.gridPosition + shiftTarget
        gridlet = Gridlet.at(newGridPosition)

        gridlet.contents = .arkon
        gridlet.sprite = sprite
    }
}
