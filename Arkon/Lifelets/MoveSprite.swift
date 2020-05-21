import SpriteKit

final class MoveSprite: Dispatchable {
    static let histogram1 = Debug.Histogram()
    static let histogram2 = Debug.Histogram()

    internal override func launch() { SceneDispatch.shared.schedule { [unowned self] in self.moveSprite() } }

    func moveSprite() {
        Debug.debugColor(scratch.stepper, .brown, .orange)

        let shuttle = (scratch.cellShuttle)!

        Debug.log(level: 167) { "MoveSprite \(scratch.stepper.name)" }

        if shuttle.fromCell == nil {
            Debug.log(level: 167) { "Resting \(six(scratch.stepper.name))" }
            Debug.debugColor(scratch.stepper, .blue, .cyan)
            MoveSprite.restArkon(scratch.stepper) { self.scratch.dispatch!.releaseShuttle() }
            return
        }

        hardAssert(shuttle.fromCell !== shuttle.toCell)
        hardAssert(shuttle.fromCell != nil && shuttle.toCell != nil)
        hardAssert((shuttle.fromCell?.isLocked) ?? false && (shuttle.toCell?.isLocked ?? false))

        let hotKey = (shuttle.toCell)!
        let position = hotKey.randomScenePosition ?? hotKey.scenePosition

//        let duration1 = scratch.debugStart == 0 ? 0 : Debug.debugStats(startedAt: scratch.debugStart, scale: UInt64(1e6 * 5))
//        let duration2 = scratch.debugStart == 0 ? 0 : Debug.debugStats(startedAt: scratch.debugStart, scale: 1e8 * 4)

//        MoveSprite.histogram1.histogrize(Double(duration1), scale: 100, inputRange: 0..<1)
//        if duration2 > 0 { MoveSprite.histogram2.histogrize(100 * duration2 / Double(stepper.net.layers.reduce(0, +)), scale: 100, inputRange: 0..<1) }

        MoveSprite.moveAction(scratch.stepper, to: position) {
            Debug.log(level: 167) { "End of move action for \(six(self.scratch.stepper.name))" }
            Debug.debugColor(self.scratch.stepper, .blue, .gray)

            self.scratch.debugStart = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)

            self.scratch.dispatch!.moveStepper()
        }
    }

    private static func moveAction(_ stepper: Stepper, to targetPosition: CGPoint, _ onComplete: @escaping () -> Void) {
        let js = stepper.dispatch.scratch.jumpSpec!
        let moveDuration = js.durationSeconds

        Debug.log(level: 104) { "Moving \(six(stepper.name)) at \(js.speedMetersPerSec)m/sec" }
        Debug.debugColor(stepper, .blue, .green)

        let move = SKAction.move(to: targetPosition, duration: moveDuration)
        stepper.sprite.run(move, completion: onComplete)
    }

    private static func restArkon(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        let rest = SKAction.wait(forDuration: 0.02)
        stepper.sprite.run(rest, completion: onComplete)
    }
}
