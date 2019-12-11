import SpriteKit

final class MoveSprite: Dispatchable {
    static let moveDuration: TimeInterval = 0.07
    static let restAction = SKAction.wait(forDuration: moveDuration)

    static func rest(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        stepper.sprite.run(restAction) { onComplete() }
    }

    deinit {
//        Log.L.write("~move sprite", level: 35)
    }

    override func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.serialQueue.async(execute: w)
//        World.shared.concurrentQueue.async(execute: w)
    }

    internal override func launch_() { moveSprite() }

    func moveSprite() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }

        guard let taxi = ch.cellTaxi_ else { preconditionFailure() }

        Log.L.write("moveSprite0 \(six(st.name)), \(ch.cellTaxi_ == nil), \(ch.cellTaxi_?.toCell == nil), \(ch.cellTaxi_?.toCell?.cell == nil))", level: 31)

        if taxi.fromCell == nil {
            MoveSprite.rest(st) { ch.stillCounter += 1; dp.releaseStage() }
            return
        }

        Log.L.write("moveSprite1 \(six(st.name))", level: 31)
        guard let hotKey = taxi.toCell?.cell else { preconditionFailure() }
        let position = hotKey.randomScenePosition ?? hotKey.scenePosition

        let moveAction =  SKAction.move(to: position, duration: MoveSprite.moveDuration)

        st.sprite.run(moveAction) { dp.moveStepper() }
    }
}
