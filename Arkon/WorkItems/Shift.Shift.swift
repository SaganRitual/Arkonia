import SpriteKit

extension Shift {
    func shift() {
        guard let st = self.shiftTarget else { fatalError() }

        oldGridlet = releaseGridlet(stepper.gridlet!)

        self.stepper.gridlet = Gridlet.at(oldGridlet!.gridPosition + st)

        let moveAction =
            SKAction.move(to: self.stepper.gridlet.scenePosition, duration: 0.1)

        stepper.sprite.run(moveAction) { [unowned self] in
            self.phase = .postShift
            self.dispatch.callAgain(runAsBarrier: true)
        }
    }

    func releaseGridlet(_ gridlet: Gridlet) -> GridletCopy {
        let copy = GridletCopy(from: gridlet)

        gridlet.sprite = nil
        gridlet.contents = .nothing
        gridlet.gridletIsEngaged = false

        return copy
    }
}

extension Shift {
    func postShift() {
        guard let ng = stepper.gridlet else { fatalError() }
        print(
            "s",
            ng.previousContents,
            ng.contents,
            dispatch.stepper.oldGridlet?.previousContents ?? .unknown,
            dispatch.stepper.oldGridlet?.contents ?? .unknown
        )
        if ng.contents == .nothing { dispatch.funge(); return }
        dispatch.eat()
    }
}
