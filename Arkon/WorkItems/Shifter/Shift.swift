import SpriteKit

extension Shifter {
    func moveSprite(_ onComplete: @escaping (Bool) -> Void) {
        assert(runType == .barrier)

        guard let gcc = dispatch.gridCellConnector as? SafeStage else { fatalError() }

        let didMove = gcc.to.gridPosition != gcc.from.gridPosition

        let moveDuration: TimeInterval = 0.1
        let moveAction = didMove ?
            SKAction.move(
                to: gcc.to.randomScenePosition ?? gcc.to.scenePosition, duration: moveDuration
            ) :
            SKAction.wait(forDuration: moveDuration)

        stepper.sprite.run(moveAction) { onComplete(didMove) }
    }

    func shift() {
        guard let gcc = dispatch.gridCellConnector as? SafeStage else { fatalError() }

        gcc.move()
    }
}

extension Shifter {
    func postShift() {
        guard let gcc = dispatch.gridCellConnector as? SafeStage else { fatalError() }

        if gcc.willMove && gcc.to.contents != .nothing {
            dispatch.eat()
            return
        }

        dispatch.gridCellConnector = nil
        dispatch.funge()
    }
}
