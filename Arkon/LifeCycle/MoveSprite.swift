import SpriteKit

final class MoveSprite: Dispatchable {
    static let histogram1 = Debug.Histogram()
    static let histogram2 = Debug.Histogram()

    internal override func launch() { SceneDispatch.shared.schedule(moveSprite) }

    func moveSprite() {
        Debug.debugColor(stepper, .brown, .orange)

        guard let js = stepper.jumpSpec else {
            Debug.debugColor(stepper, .blue, .cyan)
            MoveSprite.restArkon(stepper, stepper.dispatch!.disengageGrid)
            return
        }

        let moveAction = js.toVirtualScenePosition == nil ?
            MoveSprite.moveAction : MoveSprite.teleportAction

        moveAction(stepper) {
            Debug.debugColor(self.stepper, .blue, .red)
            self.stepper.dispatch!.moveStepper()
        }
    }

    private static func teleportAction(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        let js = stepper.jumpSpec!
        let moveHalfDuration = js.durationSeconds / 2

        let fadeOut = SKAction.fadeOut(withDuration: moveHalfDuration)
        let fadeIn = SKAction.fadeIn(withDuration: moveHalfDuration)
        let move = SKAction.run { stepper.thorax.position = js.toCell.scenePosition }
        let sequence = SKAction.sequence([fadeOut, move, fadeIn])

        stepper.thorax.run(sequence, completion: onComplete)
    }

    private static func moveAction(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        let js = stepper.jumpSpec!
        let moveDuration = js.durationSeconds

        Debug.debugColor(stepper, .blue, .green)

        let move = SKAction.move(to: js.toCell.scenePosition, duration: moveDuration)
        stepper.thorax.run(move, completion: onComplete)
    }

    private static func restArkon(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        Debug.log(level: 198) { "rest arkon \(stepper.name)" }
        let rest = SKAction.wait(forDuration: 0.02)
        stepper.thorax.run(rest, completion: onComplete)
    }
}
