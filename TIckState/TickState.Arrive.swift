import GameplayKit

extension TickState {
    class Arrive: TickStateBase {
        var leaveState: TickState = .start
        var oldGridlet: Gridlet?
        var newGridlet: Gridlet?

        override func enter() { getGridlets() }

        override func leave(to state: TickState) {
            updateGridletContents()
        }

        override func work() -> TickState {
            touchFood()
            return leaveState
        }

        func eatManna(_ manna: Manna) {
            let sprite = manna.sprite

            let harvested = sprite.manna.harvest()
            metabolism.absorbEnergy(harvested)
            metabolism.inhale()
            manna.beEaten()
        }

        func getGridlets() {
            guard let og = stepper?.gridlet else { print("stepper gone in enter"); return }

            og.sprite = nil
            og.contents = .nothing
            oldGridlet = og

            guard let shiftable = statum?.states[.shiftable] as? TickState.Shift
                else { fatalError() }

            let newGridPosition = og.gridPosition + shiftable.shiftTarget
            newGridlet = Gridlet.at(newGridPosition)
        }

        func touchArkon(_ victimStepper: Stepper) {
            if self.metabolism.mass > (victimStepper.metabolism.mass * 1.25) {
                self.metabolism.parasitize(victimStepper.metabolism)

                victimStepper.tickStatum?.statumLeave(to: .apoptosize)
                leaveState = .start
//                print("wd predator")
//            } else {
//                victimStepper.metabolism.parasitize(self.metabolism)
//
//                victimStepper.tickStatum?.states[.colorize]?.go()
//                leaveState = .apoptosize
//                print("wd prey")
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
            guard let og = stepper?.gridlet else { fatalError() }

            og.contents = .nothing
            og.sprite = nil

            guard let shiftable = statum?.states[.shiftable] as? TickState.Shift
                else { fatalError() }

            let newGridPosition = og.gridPosition + shiftable.shiftTarget
            let ng = Gridlet.at(newGridPosition)

            ng.contents = .arkon
            ng.sprite = sprite

            stepper?.gridlet = ng
        }
    }
}
