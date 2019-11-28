import SpriteKit

final class Apoptosize: Dispatchable {
    var scratch: Scratchpad?

    init(_ scratch: Scratchpad) { self.scratch = scratch }
}

extension Apoptosize {
    func launch() {
        guard let sc = self.scratch else { fatalError() }
        guard let st = sc.stepper else { fatalError() }
        guard let sp = st.sprite else { fatalError() }
        guard let no = st.nose else { fatalError() }

        let action = SKAction.run {
            assert(Display.displayCycle == .actions)

            sp.removeAllActions()

            Wangkhi.spriteFactory.noseHangar.retireSprite(no)
            Wangkhi.spriteFactory.arkonsHangar.retireSprite(sp)
        }

        GriddleScene.arkonsPortal.run(action) {
            // Counting on this to be the only strong ref to the stepper
            Stepper.releaseStepper(st, from: sp)
        }
    }
}
