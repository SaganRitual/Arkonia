import SpriteKit

extension Stepper {
    func apoptosize() {
        if isApoptosizing {
            print("already apop 1")
            return
        }

        isApoptosizing = true

        let action = SKAction.run { [weak self] in
            guard let myself = self else {
                print("already apop 2")
                return
            }

            myself.apoptosize_()
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
