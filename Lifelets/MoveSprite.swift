import SpriteKit

final class MoveSprite: Dispatchable {
    static let moveDuration: TimeInterval = 0.1
    static let restAction = SKAction.wait(forDuration: moveDuration)

    static func rest(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        stepper.sprite.run(restAction) { Grid.serialQueue.async(execute: onComplete) }
    }

    internal override func launch() { moveSprite() }

    func moveSprite() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }
        Log.L.write("MoveSprite \(six(st.name))", level: 71)

        if shuttle.fromCell == nil {
            Debug.debugColor(st, .red, .cyan)
            MoveSprite.rest(st) { dp.releaseStage() }
            return
        }

        Debug.debugColor(st, .red, .magenta)

        guard let hotKey = shuttle.toCell?.bell else { preconditionFailure() }
        let position = hotKey.randomScenePosition ?? hotKey.scenePosition

        let moveAction = SKAction.move(to: position, duration: MoveSprite.moveDuration)
        st.sprite.run(moveAction) { dp.moveStepper() }
    }
}
