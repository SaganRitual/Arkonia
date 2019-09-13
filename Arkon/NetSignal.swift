import SpriteKit

enum Stage { case notSet, selfOk, stepperOk, metabolismOk, moveOk }

struct StepperNetSignal {
    weak var stepper: Stepper?

    mutating func inject(_ stepper: Stepper) {
        self.stepper = stepper
    }

    func go() {
        var shiftTarget = AKPoint.zero

        guard let theStepper = stepper else { return }
        guard let theSprite = theStepper.sprite else { return }

        let goAction = SKAction.run({

//            guard let myself = self else { return }

            shiftTarget = AKPoint.zero

            if !theStepper.metabolize() { return }

            theStepper.metabolism.tick()  // Jesu Christi this is ugly

            shiftTarget = theStepper.selectMoveTarget(theStepper.loadSenseData())

            if shiftTarget == AKPoint.zero { return }

            let newGridlet = Gridlet.at(theStepper.gridlet.gridPosition + shiftTarget)

            let goStep = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)

            let goContents = SKAction.run {
                defer {
                    theStepper.gridlet.sprite = nil
                    theStepper.gridlet.contents = .nothing
                    newGridlet.contents = .arkon
                    newGridlet.sprite = theStepper.sprite
                    theStepper.gridlet = newGridlet
                }

               self.touchFood(eater: theStepper, foodLocation: newGridlet)
            }

            let goSequence = SKAction.sequence([goStep, goContents])
            theSprite.run(goSequence) { self.go() }

        }, queue: theStepper.core.netQueue)

        theSprite.run(goAction)
    }

    func touchFood(eater: Stepper, foodLocation: Gridlet) {

        var userDataKey = SpriteUserDataKey.karamba

        switch foodLocation.contents {
        case .arkon:
            userDataKey = .stepper

            if let otherSprite = foodLocation.sprite,
                let otherUserData = otherSprite.userData,
                let otherAny = otherUserData[userDataKey],
                let otherStepper = otherAny as? Stepper
            {
                eater.touchArkon(otherStepper)
            }

        case .manna:
            userDataKey = .manna

            if let otherSprite = foodLocation.sprite,
                let otherUserData = otherSprite.userData,
                let otherAny = otherUserData[userDataKey],
                let manna = otherAny as? Manna
            {
                eater.touchManna(manna)
            }

        case .nothing: break
        }

    }
}
