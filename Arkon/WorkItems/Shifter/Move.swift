import SpriteKit

extension Shifter {
    func moveSprite(_ onComplete: @escaping (Bool) -> Void) {

        guard let gcc = dispatch.gridCellConnector as? SafeStage else { fatalError() }

        let moveDuration: TimeInterval = 0.1
        let moveAction = gcc.willMove ?
            SKAction.move(
                to: gcc.to.randomScenePosition ?? gcc.to.scenePosition, duration: moveDuration
            ) :
            SKAction.wait(forDuration: moveDuration)

        stepper.sprite.run(moveAction) { onComplete(gcc.willMove) }
    }

    func shift() {
        guard let gcc = dispatch.gridCellConnector as? SafeStage else { fatalError() }

        gcc.move()
        stepper.gridCell = GridCell.at(gcc.to)
    }
}

extension Shifter {
    func postShift() {
        guard let gcc = dispatch.gridCellConnector as? SafeStage else { fatalError() }

        if gcc.willMove && gcc.to.contents != .nothing {
            print("postShift \(six(stepper.name)), from \(gcc.from.gridPosition), \((gcc.from.contents)), to \(gcc.to.gridPosition), \(six(gcc.from.sprite?.name)) \(six(gcc.to.sprite?.name)) contents \(gcc.to.contents)")
            dispatch.eat()
            return
        }

        dispatch.gridCellConnector = nil
        dispatch.funge()
    }
}
