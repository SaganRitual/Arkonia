import SpriteKit

extension Shift {
    func moveSprite(_ onComplete: @escaping (Bool) -> Void) {
        assert(runType == .barrier)

        guard let to = gridletEngager.gridletTo,
            let from = gridletEngager.gridletFrom else { fatalError() }

        self.didMove = to.gridPosition != from.gridPosition
        assert(self.didMove == (to.gridPosition != stepper.gridlet.gridPosition))

        let moveDuration: TimeInterval = 0.1
        let moveAction = self.didMove ?
            SKAction.move(
                to: to.randomScenePosition ?? to.scenePosition, duration: moveDuration
            ) :
            SKAction.wait(forDuration: moveDuration)

        stepper.sprite.run(moveAction) { onComplete(self.didMove) }
    }

    func shift() {
        assert(runType == .barrier)
        assert(self.didMove)

        guard let to = gridletEngager.gridletTo else { fatalError() }

        Grid.shared.serialQueue.sync {
//            print("shst move")
            dispatch.gridletEngager.move_()

            stepper.gridlet = Gridlet.at(to.gridPosition)
//            print("sge2", stepper.gridlet.gridPosition)
        }
    }
}

extension Shift {
    func postShift() {
        assert(runType == .barrier)

        let c = dispatch.gridletEngager.gridletTo!.contents

//        print("A")
        if self.didMove && c != .nothing {
//            print("B", c)
            dispatch.eat()
            return
        }
//        print("C")

        dispatch.gridletEngager.deinit_(dispatch)
        dispatch.funge()
    }
}
