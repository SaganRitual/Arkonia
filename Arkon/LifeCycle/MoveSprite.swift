import SpriteKit

final class MoveSprite: Dispatchable {
    static let histogram1 = Debug.Histogram()
    static let histogram2 = Debug.Histogram()

    internal override func launch() { SceneDispatch.shared.schedule(moveSprite) }

    func moveSprite() {
        Debug.debugColor(stepper, .brown, .orange)

        let j = stepper.jumpSpec!
        let fp = j.fromCell ?? j.toCell
        Debug.log(level: 191) { "moveSprite from \(fp.cell!.gridPosition) to \(j.toCell.cell!.gridPosition)" }

        if j.fromCell == nil {
            Debug.debugColor(stepper, .blue, .cyan)
            MoveSprite.restArkon(stepper, stepper.dispatch!.disengageGrid)
            return
        }

        let moveAction = j.toCell.virtualScenePosition == nil ?
            MoveSprite.moveAction : MoveSprite.teleportAction

        moveAction(stepper, j.toCell.cell!.scenePosition) {
            Debug.debugColor(self.stepper, .blue, .red)
            self.stepper.dispatch!.moveStepper()
        }
    }

    private static func teleportAction(_ stepper: Stepper, to targetPosition: CGPoint, _ onComplete: @escaping () -> Void) {
        let js = stepper.jumpSpec!
        let moveHalfDuration = js.durationSeconds / 2

        let fadeOut = SKAction.fadeOut(withDuration: moveHalfDuration)
        let fadeIn = SKAction.fadeIn(withDuration: moveHalfDuration)
        let move = SKAction.run { stepper.sprite.position = targetPosition }
        let sequence = SKAction.sequence([fadeOut, move, fadeIn])

        stepper.sprite.run(sequence, completion: onComplete)
    }

    private static func moveAction(_ stepper: Stepper, to targetPosition: CGPoint, _ onComplete: @escaping () -> Void) {
        let js = stepper.jumpSpec!
        let moveDuration = js.durationSeconds

        Debug.debugColor(stepper, .blue, .green)

        let move = SKAction.move(to: targetPosition, duration: moveDuration)
        stepper.sprite.run(move, completion: onComplete)
    }

    private static func restArkon(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        let rest = SKAction.wait(forDuration: 0.02)
        stepper.sprite.run(rest, completion: onComplete)
    }
}
