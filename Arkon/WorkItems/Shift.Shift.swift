import SpriteKit

extension Shift {
    func shift(_ onComplete: @escaping () -> Void) {
        guard let st = self.shiftTarget else { fatalError() }

        oldGridlet = stepper.gridlet!
        self.stepper.gridlet = st

        let moveAction =
            SKAction.move(to: self.stepper.gridlet.scenePosition, duration: 0.1)

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
