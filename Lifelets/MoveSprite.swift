import SpriteKit

final class MoveSprite: Dispatchable {
    internal override func launch() { SceneDispatch.schedule { self.moveSprite() } }

    func moveSprite() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }

        Debug.log(level: 156) { "MoveSprite \(st.name)" }

        if shuttle.fromCell == nil {
            Debug.log(level: 156) { "Resting \(six(st.name))" }
            Debug.debugColor(st, .red, .cyan)
            MoveSprite.restArkon(st) { dp.releaseShuttle() }
            return
        }

        assert(shuttle.fromCell !== shuttle.toCell)
        assert(shuttle.fromCell != nil && shuttle.toCell != nil)

        guard let hotKey = shuttle.toCell?.gridCell else { fatalError() }
        let position = hotKey.randomScenePosition ?? hotKey.scenePosition

        MoveSprite.moveAction(st, to: position) {
            Debug.log(level: 104) { "End of move action for \(six(st.name))" }
            Debug.debugColor(st, .red, .cyan)
            dp.moveStepper()
        }
    }

    private static func makeRestAction() -> SKAction? {
        if Arkonia.arkonMinRestDuration == 0 ||
            Arkonia.arkonMaxRestDuration == 0 { return nil }

        let restDuration: TimeInterval

        if Arkonia.arkonMinRestDuration == Arkonia.arkonMaxRestDuration {
            restDuration = Arkonia.arkonMinMoveDuration
        } else {
            restDuration = TimeInterval.random(
                in: Arkonia.arkonMinRestDuration..<Arkonia.arkonMaxRestDuration
            )
        }

        return SKAction.wait(forDuration: restDuration)
    }

    private static func moveAction(_ stepper: Stepper, to position: CGPoint, _ onComplete: @escaping () -> Void) {
        precondition(Arkonia.arkonMinMoveDuration > 0 && Arkonia.arkonMaxMoveDuration > 0)

        let moveDuration: TimeInterval

        if Arkonia.arkonMinMoveDuration == Arkonia.arkonMaxMoveDuration {
            moveDuration = Arkonia.arkonMinMoveDuration
        } else {
            moveDuration = TimeInterval.random(in: Arkonia.arkonMinMoveDuration..<Arkonia.arkonMaxMoveDuration)
        }

        if moveDuration == 0 { onComplete(); return }

        Debug.log(level: 104) { "Moving \(six(stepper.name))" }
        Debug.debugColor(stepper, .red, .magenta)

        let move = SKAction.move(to: position, duration: moveDuration)
        var aSequence = [move]
        if let ra = makeRestAction() { aSequence.append(ra) }
        let sequence = SKAction.sequence(aSequence)
        stepper.sprite.run(sequence, completion: onComplete)
    }

    private static func restArkon(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        guard let ra = makeRestAction() else { onComplete(); return }
        stepper.sprite.run(ra, completion: onComplete)
    }
}
