import SpriteKit

extension Stepper {
    func moveSprite() {
        SceneDispatch.shared.schedule {
            Debug.log(level: 206) { "moveSprite" }
            Debug.debugColor(self, .brown, .orange)

            guard let js = self.jumpSpec else {
                Debug.debugColor(self, .blue, .cyan)
                Stepper.restArkon(self, self.disengageGrid)
                return
            }

            let moveAction = js.toCell.virtualGridPosition == nil ?
                Stepper.moveAction : Stepper.teleportAction

            moveAction(self) {
                Debug.debugColor(self, .blue, .red)
                self.moveStepper()
            }
        }
    }

    private static func teleportAction(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        Debug.log(level: 205) { "teleport" }
        let js = stepper.jumpSpec!
        let moveHalfDuration = js.durationSeconds / 2
        let targetScenePosition = js.toCell.liveGridCell!.properties.scenePosition

        let fadeOut = SKAction.fadeOut(withDuration: moveHalfDuration)
        let fadeIn = SKAction.fadeIn(withDuration: moveHalfDuration)
        let move = SKAction.run { stepper.thorax.position = targetScenePosition }
        let sequence = SKAction.sequence([fadeOut, move, fadeIn])

        stepper.thorax.run(sequence, completion: onComplete)
    }

    private static func moveAction(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        let js = stepper.jumpSpec!
        let moveDuration = js.durationSeconds
        let scenePosition = js.toCell.liveGridCell!.properties.scenePosition

        Debug.debugColor(stepper, .blue, .green)

        let move = SKAction.move(to: scenePosition, duration: moveDuration)
        stepper.thorax.run(move, completion: onComplete)
    }

    private static func restArkon(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        let rest = SKAction.wait(forDuration: 0.02)
        stepper.thorax.run(rest, completion: onComplete)
    }
}
