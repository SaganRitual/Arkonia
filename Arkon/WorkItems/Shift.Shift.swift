import SpriteKit

extension Shift {
    static var ssCount = 0
    func shift(_ onComplete: @escaping () -> Void) {
        guard let st = self.shiftTarget else { fatalError() }

        let stationary = (self.stepper.gridlet == st)

        oldGridlet = stepper.gridlet!
        self.stepper.gridlet = st

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
        guard let ng = stepper.gridlet else { fatalError() }

        if ng.contents == .nothing {
            ng.releaseGridlet_()
            dispatch.funge()
            return
        }

        dispatch.eat()
    }
}
