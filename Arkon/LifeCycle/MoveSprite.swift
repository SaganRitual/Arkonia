import SpriteKit

extension Stepper {
    func moveSprite() {
        Debug.log(level: 213) { "moveSprite.0" }
        Debug.debugColor(self, .brown, .orange)

        guard let js = self.jumpSpec else {
            Debug.log(level: 213) { "moveSprite.1" }
            Debug.debugColor(self, .blue, .cyan)

            // The call to disengageGrid also reengages and restarts
            // the life cycle
            Stepper.restArkon(self, disengageGrid)
            return
        }

        let moveAction = js.to.sensorSS.virtualGridPosition == nil ?
            Stepper.moveAction : Stepper.teleportAction

        moveAction(self) {
            Debug.log(level: 213) { "moveSprite.2" }
            Debug.debugColor(self, .blue, .red)
            self.moveStepper()
        }
    }

    private static func teleportAction(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        let js = stepper.jumpSpec!
        let moveHalfDuration = js.durationSeconds / 2
        let targetScenePosition = js.to.cellSS.properties.scenePosition

        let fadeOut =  SKAction.fadeOut(withDuration: moveHalfDuration)
        let fadeIn =   SKAction.fadeIn(withDuration: moveHalfDuration)
        let move =     SKAction.run { stepper.thorax.position = targetScenePosition }
        let sequence = SKAction.sequence([fadeOut, move, fadeIn])

        Debug.log(level: 211) {
            "sprite teleport"
            + " from \(js.from.properties.gridPosition)"
            + " to \(js.to.cellSS.properties.gridPosition)"
        }

        SceneDispatch.shared.schedule("teleportAction") {
            stepper.thorax.run(sequence) { mainDispatch(onComplete) }
        }
    }

    private static func moveAction(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        let js = stepper.jumpSpec!
        let moveDuration = js.durationSeconds
        let scenePosition = js.to.cellSS.properties.scenePosition

        Debug.debugColor(stepper, .blue, .green)

        Debug.log(level: 211) {
            "sprite move from"
            + " \(js.from.properties.gridPosition)"
            + " \(js.to.cellSS.properties.gridPosition)"
        }

        let move = SKAction.move(to: scenePosition, duration: moveDuration)

        SceneDispatch.shared.schedule("moveAction") {
            stepper.thorax.run(move) { mainDispatch(onComplete) }
        }
    }

    private static func restArkon(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        let rest = SKAction.wait(forDuration: 0.02)

        SceneDispatch.shared.schedule("restArkon") {
            stepper.thorax.run(rest) { mainDispatch(onComplete) }
        }
    }
}
