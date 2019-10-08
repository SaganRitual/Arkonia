import SpriteKit

extension TickState {
    class Apoptosize: TickStateBase {
        override func enter() {
            if !isViable() {
                print("Already apoptosizing/dead?", stepper?.core.selectoid.fishNumber ?? -1)
            }
        }

        override func isViable() -> Bool {
            return stepper?.isApoptosizing == false &&
                stepper?.isAlive == true &&
                statum?.currentState != .dead
        }

        override func work() -> TickState {
            let action = SKAction.run { [weak self] in
                guard let myself = self, myself.isViable() else {
                    return
                }

                myself.apoptosize()
                myself.stepper?.isAlive = false
                myself.stepper?.isApoptosizing = false
            }

            statum?.action = action
            statum?.actioner = sprite

            return .dead
        }

        func apoptosize() {
            assert(Display.displayCycle == .actions)

            guard let sprite = sprite else { return }
            guard let stepper = stepper else { return }

            stepper.isApoptosizing = true

            sprite.removeAllActions()

            stepper.gridlet.contents = .nothing
            stepper.gridlet.sprite = nil

            let core = stepper.core
            core.spriteFactory.noseHangar.retireSprite(stepper.core.nose)
            core.spriteFactory.arkonsHangar.retireSprite(sprite)

            guard let ud = sprite.userData else { return }
            ud[SpriteUserDataKey.stepper] = nil

            self.stepper?.sprite = nil
        }
    }
}
