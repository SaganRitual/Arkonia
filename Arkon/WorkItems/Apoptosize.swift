import SpriteKit

extension Stepper {
    func apoptosize() {
        let action = SKAction.run { [unowned self] in self.apoptosize_() }

        sprite.run(action)
    }

    private func apoptosize_() {
        assert(Display.displayCycle == .actions)

        sprite.removeAllActions()

        core.spriteFactory.noseHangar.retireSprite(core.nose)
        core.spriteFactory.arkonsHangar.retireSprite(sprite)

        guard let ud = sprite.userData else { return }
        ud[SpriteUserDataKey.stepper] = nil
    }
}
