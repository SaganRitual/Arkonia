import SpriteKit

extension Stepper {
    func apoptosize() {
//        print("apoptosize1")
        let action = SKAction.run { [weak self] in
            guard let myself = self else {
//                print("Bailing in apoptosize")
                return
            }
            myself.apoptosize_()
        }

        let fishNumber = self.core.selectoid.fishNumber
        sprite.run(action) { print("ap \(fishNumber)") }
//        print("apoptosize4")
    }

    private func apoptosize_() {
        assert(Display.displayCycle == .actions)
//        print("apoptosize2")

        sprite.removeAllActions()

        core.spriteFactory.noseHangar.retireSprite(core.nose)
        core.spriteFactory.arkonsHangar.retireSprite(sprite)

        guard let ud = sprite.userData else { return }
        ud[SpriteUserDataKey.stepper] = nil
//        print("apoptosize3")
    }
}
