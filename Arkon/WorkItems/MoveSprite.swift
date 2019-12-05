import SpriteKit

final class MoveSprite: Dispatchable {
    static let moveDuration: TimeInterval = 0.1
    static let restAction = SKAction.wait(forDuration: moveDuration)

    static func rest(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        stepper.sprite.run(restAction) { onComplete() }
    }

    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch

        self.wiLaunch = DispatchWorkItem { [weak self] in self?.launch_() }
    }

    private func launch_() { moveSprite() }

    func moveSprite() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }

        guard let taxi = ch.cellTaxi else { preconditionFailure() }

        Log.L.write("moveSprite0 \(six(st.name)), \(ch.cellTaxi == nil), \(ch.cellTaxi?.toCell == nil), \(ch.cellTaxi?.toCell?.cell == nil))", level: 31)

        if taxi.fromCell == nil {
            MoveSprite.rest(st) { dp.releaseStage() }
            return
        }

        Log.L.write("moveSprite1 \(six(st.name))", level: 31)
        guard let hotKey = taxi.toCell?.cell else { preconditionFailure() }
        let position = hotKey.randomScenePosition ?? hotKey.scenePosition

        let moveAction =  SKAction.move(to: position, duration: MoveSprite.moveDuration)

        st.sprite.run(moveAction) { dp.moveStepper() }
    }
}
