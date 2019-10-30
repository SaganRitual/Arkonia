import SpriteKit

final class Apoptosize: Dispatchable {
    weak var dispatch: Dispatch!
    var runningAsBarrier: Bool { return dispatch.runningAsBarrier }
    var stepper: Stepper { return dispatch.stepper }

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func go() { aApoptosize() }

    deinit {
//        print("wtf")
    }
}

extension Apoptosize {
    private func aApoptosize() {
        assert(runningAsBarrier == true)

        let action = SKAction.run { [unowned self] in
            assert(Display.displayCycle == .actions)

             guard let s = self.stepper.sprite else { fatalError() }
            guard let n = self.stepper.nose else { fatalError() }

            s.removeAllActions()

            Wangkhi.spriteFactory.noseHangar.retireSprite(n)
            Wangkhi.spriteFactory.arkonsHangar.retireSprite(s)

            guard let ud = s.userData else { return }

            // Counting on this to be the only strong ref to the stepper
            ud[SpriteUserDataKey.stepper] = nil
        }

        GriddleScene.arkonsPortal.run(action)
    }
}
