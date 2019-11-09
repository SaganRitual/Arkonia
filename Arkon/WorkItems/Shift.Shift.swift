import SpriteKit

extension Shift {
    static var ssCount = 0
    func shift(_ onComplete: @escaping () -> Void) {
        assert(runType == .barrier)

        guard let to = gridletEngager.gridletTo,
            let from = gridletEngager.gridletFrom else { fatalError() }

        let stationary = to.gridPosition != from.gridPosition

        if !stationary { gridletEngager.move() }

        let moveDuration: TimeInterval = 0.1
        let moveAction = stationary ?
            SKAction.wait(forDuration: moveDuration) :
            SKAction.move(to: to.scenePosition, duration: moveDuration)

        stepper.sprite.run(moveAction) { onComplete() }
    }
}

extension Shift {
    func postShift() {
        assert(runType == .barrier)

        guard let to = gridletEngager.gridletTo,
            let from = gridletEngager.gridletFrom else { fatalError() }

        let stationary = to.gridPosition == from.gridPosition

        if stationary || to.contents == .nothing {
            dispatch.gridletEngager = nil
            dispatch.funge()
            return
        }

        print("ps eat")
        dispatch.eat()
    }
}
