import SpriteKit

enum Stage { case notSet, selfOk, stepperOk, metabolismOk, moveOk }

struct StepperNetSignal {
    weak var stepper: Stepper?

    mutating func inject(_ stepper: Stepper) {
        self.stepper = stepper
    }

    func go() {
        var shiftTarget = AKPoint.zero

        if stepper?.sprite == nil { return }

        let goAction = SKAction.run({

            if self.stepper?.sprite == nil { return }

            shiftTarget = AKPoint.zero

            if !(self.stepper?.metabolize() ?? false) { return }

            self.stepper?.metabolism.tick()  // Jesu Christi this is ugly

            shiftTarget = self.stepper?.selectMoveTarget(self.stepper!.loadSenseData()) ?? AKPoint.zero

            if shiftTarget == AKPoint.zero { return }

            let newGridlet = Gridlet.at((self.stepper?.gridlet.gridPosition ?? AKPoint.zero) + shiftTarget)

            let goStep = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)

            let goContents = SKAction.run {
                defer {
                    self.stepper?.gridlet.sprite = nil
                    self.stepper?.gridlet.contents = .nothing

                    newGridlet.contents = .arkon
                    newGridlet.sprite = self.stepper?.sprite

                    self.stepper?.gridlet = newGridlet
                }

               self.touchFood(eater: self.stepper!, foodLocation: newGridlet)
            }

            let goSequence = SKAction.sequence([goStep, goContents])
            self.stepper?.sprite?.run(goSequence) { self.go() }

        }, queue: stepper!.core.netQueue)

        stepper!.sprite!.run(goAction)
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
