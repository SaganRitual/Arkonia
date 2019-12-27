import SpriteKit

final class MoveSprite: Dispatchable {
    static let moveDuration: TimeInterval = 0.1
    static let restAction = SKAction.wait(forDuration: moveDuration)

    static func rest(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        stepper.sprite.run(restAction) { Grid.shared.serialQueue.async { onComplete() } }
    }

    deinit {
//        Log.L.write("~move sprite", level: 35)
    }

    internal override func launch() { moveSprite() }

    func moveSprite() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        writeDebug("MoveSprite \(six(st.name))", scratch: ch)

        precondition(
            (ch.cellShuttle?.toCell != nil && (ch.cellShuttle?.toCell?.sprite == nil || ch.cellShuttle?.toCell?.sprite?.name == st.name) && ch.engagerKey == nil) ||
                (ch.cellShuttle?.toCell == nil && ch.engagerKey?.sprite?.name == st.name) ||
                (ch.cellShuttle?.toCell?.sprite != nil && (ch.cellShuttle?.toCell?.sprite?.name == st.name) || ((ch.cellShuttle?.toCell?.sprite?.getManna(require: false)) != nil)) ||
                (ch.cellShuttle?.toCell?.sprite?.name != ch.cellShuttle?.fromCell?.sprite?.name && ch.cellShuttle?.fromCell?.sprite?.getStepper(require: false)?.name == ch.cellShuttle?.fromCell?.sprite?.name) ||
                (ch.engagerKey?.sprite?.name == st.name && ch.cellShuttle?.toCell == nil)
        )

        guard let shuttle = ch.cellShuttle else { preconditionFailure() }

//        guard let p = shuttle.toCell?.gridPosition else { preconditionFailure() }
//        ch.debugReport.append("move(\(ch.serializer) \(six(st.name)) to \(p)")

        Log.L.write("moveSprite0 \(six(st.name)), \(ch.cellShuttle == nil), \(ch.cellShuttle?.toCell == nil), \(ch.cellShuttle?.toCell?.bell == nil))", level: 31)

        if shuttle.fromCell == nil {
            Debug.debugColor(st, .red, .cyan)
            MoveSprite.rest(st) { dp.releaseStage() }
            return
        }

        Debug.debugColor(st, .red, .magenta)

        Log.L.write("moveSprite1 \(six(st.name))", level: 31)
        precondition(
            (ch.cellShuttle?.toCell?.sprite == nil &&
            ch.cellShuttle?.fromCell?.sprite == nil) || ch.engagerKey == nil
        )
        guard let hotKey = shuttle.toCell?.bell else { preconditionFailure() }
        let position = hotKey.randomScenePosition ?? hotKey.scenePosition

        let moveAction =  SKAction.move(to: position, duration: MoveSprite.moveDuration)

        precondition(
            (ch.cellShuttle?.toCell?.sprite == nil &&
            ch.cellShuttle?.fromCell?.sprite == nil) || ch.engagerKey == nil
        )
        st.sprite.run(moveAction) { Grid.shared.serialQueue.async { dp.moveStepper() } }
    }
}
