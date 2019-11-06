import SpriteKit

extension Shift {
    static var ssCount = 0
    func shift(_ onComplete: @escaping () -> Void) {
        assert(runType == .barrier)

        guard let landingGridlet = self.shiftTarget else { fatalError() }

        stepper.shiftTracker.beforeMoveStart = GridletCopy(from: stepper.gridlet!, runType: runType)
        stepper.shiftTracker.beforeMoveStop = GridletCopy(from: landingGridlet, runType: runType)

        let stationary = (self.stepper.gridlet == landingGridlet)

        if !stationary {
            if let sp = landingGridlet.sprite, let st = Stepper.getStepper(from: sp, require: false) {
                print("?")
                st.gridlet = nil
            }
        }

        landingGridlet.sprite = stepper.sprite
        landingGridlet.contents = .arkon

        stepper.gridlet = landingGridlet

        let moveDuration: TimeInterval = 0.1
        let moveAction = stationary ?
            SKAction.wait(forDuration: moveDuration) :
            SKAction.move(to: landingGridlet.scenePosition, duration: moveDuration)

        stepper.sprite.run(moveAction) { onComplete() }
    }
}

extension Shift {
    func postShift() {
        assert(runType == .barrier)

        stepper.shiftTracker.afterMoveStop = GridletCopy(from: stepper.gridlet, runType: runType)

        guard let bmStart = stepper.shiftTracker.beforeMoveStart else { fatalError() }
        guard let bmStop = stepper.shiftTracker.beforeMoveStop else { fatalError() }
        guard let amStop = stepper.shiftTracker.afterMoveStop else { fatalError() }
        guard let bmStartGridlet = Gridlet.atIf(bmStart) else { fatalError() }
        guard let amStopGridlet = Gridlet.atIf(amStop) else { fatalError() }

        if bmStartGridlet === amStopGridlet || bmStop.contents == .nothing {
            amStopGridlet.disengageGridlet(runType)
            print("ps funge")
            dispatch.funge()
            return
        }

        print("ps eat")
        dispatch.eat()
    }
}
