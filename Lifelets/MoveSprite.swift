import SpriteKit

final class MoveSprite: Dispatchable {
    static let moveDuration: TimeInterval = 0.1
    static let restAction = SKAction.wait(forDuration: moveDuration)

    static func rest(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        stepper.sprite.run(restAction) { Substrate.serialQueue.async(execute: onComplete) }
    }

    internal override func launch() { moveSprite() }

    func moveSprite() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }

        if shuttle.fromCell == nil {
            Debug.log("Resting \(six(st.name))", level: 90)
            Debug.debugColor(st, .red, .cyan)
            MoveSprite.rest(st) { dp.releaseShuttle() }
            return
        }

        Debug.log("Moving \(six(st.name))", level: 88)
        Debug.debugColor(st, .red, .magenta)

        guard let hotKey = shuttle.toCell?.bell else { preconditionFailure() }
        let position = hotKey.randomScenePosition ?? hotKey.scenePosition

        let moveAction = SKAction.move(to: position, duration: MoveSprite.moveDuration)
        st.sprite.run(moveAction) { dp.moveStepper() }
    }
}
