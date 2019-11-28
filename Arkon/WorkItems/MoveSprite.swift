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

        // maybe we need a barrier to protect calls to sprite.run?
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    private func launch_() { moveSprite() }

    func moveSprite() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Log.L.write("MoveSprite.launch_ \(six(st.name))", level: 15)

        guard let gcc = ch.getStageConnector() else { preconditionFailure() }

        if gcc.fromCell == nil {
            st.sprite.run(MoveSprite.restAction) { dp.releaseStage() }
            return
        }

        let position = gcc.toCell.randomScenePosition ?? gcc.toCell.scenePosition

        let moveAction =  SKAction.move(to: position, duration: MoveSprite.moveDuration)

        st.sprite.run(moveAction) { dp.moveStepper() }
    }
}
