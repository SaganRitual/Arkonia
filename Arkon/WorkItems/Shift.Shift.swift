import SpriteKit

extension Shift {
    func shift() {
        guard let st = self.shiftTarget else { fatalError() }
        oldGridlet = stepper.gridlet
        newGridlet = Gridlet.at(oldGridlet!.gridPosition + st)

        let moveAction =
            SKAction.move(to: newGridlet!.scenePosition, duration: 0.1)

        stepper.sprite.run(moveAction, completion: postShift)
    }
}

extension Shift {
    func getResult() -> Gridlet { return self.newGridlet! }

    func postShift() {
        defer { updateGridletContents() }

        guard let ng = newGridlet else { fatalError() }
        if ng.contents == .nothing { dispatch.funge(); return }

        dispatch.eat()
    }

    private func updateGridletContents() {
        guard let ng = newGridlet, let og = oldGridlet else { fatalError() }
        og.sprite = nil
        og.contents = .nothing
        og.gridletIsEngaged = false
        self.oldGridlet = nil

        ng.contents = .arkon
        ng.sprite = stepper.sprite
        self.newGridlet = nil
    }
}
