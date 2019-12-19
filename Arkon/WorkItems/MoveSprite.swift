import SpriteKit

final class MoveSprite: Dispatchable {
    static let moveDuration: TimeInterval = 0.07
    static let restAction = SKAction.wait(forDuration: moveDuration)

    static func rest(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        stepper.sprite.run(restAction) { Grid.shared.serialQueue.async { onComplete() } }
    }

    deinit {
//        Log.L.write("~move sprite", level: 35)
    }

//    override func launch() {
//        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }
//
//        st.sprite.run(SKAction.run { self.moveSprite() })
//
////        Grid.shared.serialQueue.async(execute: w)
////        World.shared.concurrentQueue.async(execute: w)
//
//    }

    internal override func launch_() { moveSprite() }

    func moveSprite() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
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

        Log.L.write("moveSprite0 \(six(st.name)), \(ch.cellShuttle == nil), \(ch.cellShuttle?.toCell == nil), \(ch.cellShuttle?.toCell?.getCell() == nil))", level: 31)

        if shuttle.fromCell == nil {
            MoveSprite.rest(st) { ch.stillCounter += 1; dp.releaseStage() }
            return
        }

        Log.L.write("moveSprite1 \(six(st.name))", level: 31)
        precondition(
            (ch.cellShuttle?.toCell?.sprite == nil &&
            ch.cellShuttle?.fromCell?.sprite == nil) || ch.engagerKey == nil
        )
        guard let hotKey = shuttle.toCell?.getCell() else { preconditionFailure() }
        let position = hotKey.randomScenePosition ?? hotKey.scenePosition

        let moveAction =  SKAction.move(to: position, duration: MoveSprite.moveDuration)

        precondition(
            (ch.cellShuttle?.toCell?.sprite == nil &&
            ch.cellShuttle?.fromCell?.sprite == nil) || ch.engagerKey == nil
        )
        st.sprite.run(moveAction) { Grid.shared.serialQueue.async { dp.moveStepper() } }
    }
}
