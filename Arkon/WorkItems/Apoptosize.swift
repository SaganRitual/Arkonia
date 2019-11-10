import SpriteKit

final class Apoptosize: AKWorkItem {
    override func go() { aApoptosize() }

    deinit {
//        print("wtf")
    }
}

extension Apoptosize {
    private func aApoptosize() {
        let name = stepper?.name ?? "wtf name?"
        print("aa1", name)
        let action = SKAction.run { [unowned self] in
            assert(Display.displayCycle == .actions)
            print("aa2", name)

            guard let st = self.stepper else { fatalError() }
            guard let s = st.sprite else { fatalError() }
            guard let n = st.nose else { fatalError() }

            s.removeAllActions()

            Wangkhi.spriteFactory.noseHangar.retireSprite(n)
            Wangkhi.spriteFactory.arkonsHangar.retireSprite(s)

            // Counting on this to be the only strong ref to the stepper
            print("aa3", s.name ?? "no name?", s.userData!)
            Stepper.releaseStepper(st, from: s)
            print("aa4", s.name ?? "no name?", s.userData!)
        }

        GriddleScene.arkonsPortal.run(action)
    }
}
