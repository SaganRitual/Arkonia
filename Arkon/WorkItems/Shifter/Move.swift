import SpriteKit

extension Shifter {
    func moveSprite() {
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        let moveDuration: TimeInterval = 0.1
        let moveAction = gcc.willMove ?
            SKAction.move(
                to: gcc.to.randomScenePosition ?? gcc.to.scenePosition, duration: moveDuration
            ) :
            SKAction.wait(forDuration: moveDuration)

        st.sprite.run(moveAction)
    }

    func moveStepper() {
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        gcc.move()
        st.gridCell = GridCell.at(gcc.to)
    }
}

extension Shifter {
    func postMove() {
        guard let scr = scratch else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }
        guard let dp = scr.dispatch else { fatalError() }

        if gcc.willMove && gcc.to.contents != .nothing {
            dp.eat()
            return
        }

        dp.gridCellConnector = nil
        dp.funge()
    }
}
