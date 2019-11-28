import SpriteKit

final class Eat: Dispatchable {
    var manna: Manna!
    weak var scratch: Scratchpad?

    var workItemChooseBattle: DispatchWorkItem?
    var workItemChooseEdible: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch

        workItemChooseBattle = DispatchWorkItem(flags: .init(), block: chooseBattle)
        workItemChooseEdible = DispatchWorkItem(flags: .init(), block: chooseEdible)

        workItemChooseEdible?.notify(
            queue: Grid.shared.concurrentQueue,
            execute: workItemChooseBattle!
        )
    }

    func launch() {
        Grid.shared.concurrentQueue.async(execute: workItemChooseEdible!)
    }
}

extension Eat {
    private func chooseEdible() {
//        print("chooseEdible")
        guard let scr = scratch else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        switch gcc.to.contents {
        case .arkon: battleArkon()
        case .manna: battleManna()

        default: fatalError()
        }
    }

    private func chooseBattle() {
//        print("chooseBattle")
        guard let scr = scratch else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        switch gcc.to.contents {
        case .arkon: settleCombat()
        case .manna: defeatManna()

        default: fatalError()
        }
    }
}

extension Eat {
    func battleArkon() {
        print("battleArkon")
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        guard let victimSprite = gcc.to.sprite else { fatalError() }

        guard let victimStepper = Stepper.getStepper(from: victimSprite)
            else { fatalError() }

        let myMass = st.metabolism.mass
        let hisMass = victimStepper.metabolism.mass
        print("combat: \(six(st.name)) \(myMass) <-> \(hisMass) \(six(victimStepper.name))")

        st.battle = (myMass > (hisMass * 1.25)) ? (st, victimStepper) : (victimStepper, st)
        victimStepper.battle = st.battle
    }

    func battleManna() {
//        print("battleManna")
        guard let scr = scratch else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        guard let mannaSprite = gcc.to.sprite,
            let mannaUserData = mannaSprite.userData,
            let shouldBeManna = mannaUserData[SpriteUserDataKey.manna],
            let manna = shouldBeManna as? Manna
        else { fatalError() }

        self.manna = manna
    }

    func inject(_ any: Void?) { }
    func getResult() -> Manna { return manna }
}

extension Eat {
    private func defeatManna() {
//        print("defeatManna")
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }

        let harvested = self.manna.harvest()

        st.metabolism.absorbEnergy(harvested)
        st.metabolism.inhale()
//        print("dm1")
//        print("dm2")
        Grid.shared.concurrentQueue.async(flags: .barrier) {
            MannaCoordinator.shared.beEaten(self.manna.sprite)
            scr.gridCellConnector = nil
            scr.dispatch?.funge()
        }
//        print("dm3")
    }

    private func settleCombat() {
//        print("settleCombat")
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }

        guard let (victor, victim) = st.battle else { fatalError() }

        print("Combat: \(six(victor.name)) eats \(six(victim.name))")
        victor.dispatch.parasitize()
        victim.dispatch.apoptosize()
    }
}
