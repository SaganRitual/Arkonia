import SpriteKit

final class MoveSprite: Dispatchable {
    static let maxMoveDuration: TimeInterval = 0.2001
    static let maxRestDuration: TimeInterval = 0.06
    static let minMoveDuration: TimeInterval = 0.2
    static let minRestDuration: TimeInterval = 0.05

    internal override func launch() { SceneDispatch.schedule { self.moveSprite() } }

    func moveSprite() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }

        if shuttle.fromCell == nil {
            Debug.log(level: 104) { "Resting \(six(st.name))" }
            Debug.debugColor(st, .red, .cyan)
            MoveSprite.restAction(st) { dp.releaseShuttle() }
            return
        }

        assert(shuttle.fromCell !== shuttle.toCell)
        assert(shuttle.fromCell != nil && shuttle.toCell != nil)
        assert(shuttle.fromCell!.contents == .arkon)

        guard let hotKey = shuttle.toCell?.gridCell else { fatalError() }
        let position = hotKey.randomScenePosition ?? hotKey.scenePosition

        MoveSprite.moveAction(st, to: position) {
            Debug.log(level: 104) { "End of move action for \(six(st.name))" }
            Debug.debugColor(st, .red, .cyan)
            dp.moveStepper()
        }
    }

    private static func makeRestAction() -> SKAction? {
        let restDuration: TimeInterval = 0//TimeInterval.random(in: MoveSprite.minRestDuration..<MoveSprite.maxRestDuration)
        return restDuration == 0 ? nil : SKAction.wait(forDuration: restDuration)
    }

    private static func moveAction(_ stepper: Stepper, to position: CGPoint, _ onComplete: @escaping () -> Void) {
        let moveDuration = TimeInterval.random(in: MoveSprite.minMoveDuration..<MoveSprite.maxMoveDuration)
        if moveDuration == 0 { onComplete(); return }

        Debug.log(level: 104) { "Moving \(six(stepper.name))" }
        Debug.debugColor(stepper, .red, .magenta)

        let move = SKAction.move(to: position, duration: moveDuration)
//        var aSequence = [move]
//        if let ra = makeRestAction() { aSequence.append(ra) }
//        let sequence = SKAction.sequence(aSequence)
        stepper.sprite.run(move, completion: onComplete)
    }

    private static func restAction(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        guard let ra = makeRestAction() else { onComplete(); return }
        stepper.sprite.run(ra, completion: onComplete)
    }
}
