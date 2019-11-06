import SpriteKit

extension Shift {
    static var ssCount = 0
    func shift(_ onComplete: @escaping () -> Void) {
        guard let st = self.shiftTarget else { fatalError() }

        copyOfOldGridlet = GridletCopy(from: stepper.gridlet!)

        let stationary = (self.stepper.gridlet == st)

        self.stepper.gridlet = st
        self.stepper.gridlet.contents = .arkon

        let moveDuration: TimeInterval = 0.1
        let moveAction = stationary ?
            SKAction.wait(forDuration: moveDuration) :
            SKAction.move(to: self.stepper.gridlet.scenePosition, duration: moveDuration)

        stepper.sprite.run(moveAction) { onComplete() }
    }
}

extension Gridlet {
    func releaseGridlet_() {
        sprite = nil
        contents = .nothing
        gridletIsEngaged = false
    }
}

extension Shift {
    func postShift() {
        if capturedFood == .nothing { return }
        if let st = shiftTarget, let og = copyOfOldGridlet, let ai = Gridlet.atIf(og),
            st === ai {
            ai.releaseGridlet()
            dispatch.funge()
            return
        }

        dispatch.eat()
    }
}
