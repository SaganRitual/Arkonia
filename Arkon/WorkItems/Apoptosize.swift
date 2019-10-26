import SpriteKit

extension Stepper {
    func apoptosize() {
        let action = SKAction.run { [weak self] in
            if (self?.isApoptosizing ?? true) {
                print("already apop 1")
                return
            }

            self?.isApoptosizing = true
            self?.apoptosize_()
        }

        sprite.run(action)
    }

    private func apoptosize_() {
        assert(Display.displayCycle == .actions)

        sprite.removeAllActions()

        ArkonFactory.spriteFactory.noseHangar.retireSprite(nose)
        ArkonFactory.spriteFactory.arkonsHangar.retireSprite(sprite)

        guard let ud = sprite.userData else { return }

        // Counting on this to be the only strong ref to the stepper
        ud[SpriteUserDataKey.stepper] = nil
    }
}
