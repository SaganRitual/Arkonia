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
        guard let scr = scratch else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        switch gcc.to.contents {
        case .arkon: battleArkon()
        case .manna: battleManna()

        default: fatalError()
        }
    }

    private func chooseBattle() {
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
        guard let scr = scratch else { fatalError() }
        guard let dp = scr.dispatch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        guard let victimSprite = gcc.to.sprite else { fatalError() }

        guard let victimStepper = Stepper.getStepper(from: victimSprite)
            else { fatalError() }

        let myMass = dp.stepper.metabolism.mass
        let hisMass = victimStepper.metabolism.mass
        print("combat: \(dp.stepper.name) \(myMass) <-> \(hisMass) \(victimStepper.name)")

        scr.battle = (myMass > (hisMass * 1.25)) ? (st, victimStepper) : (victimStepper, st)
    }

    func battleManna() {
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
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }

        let harvested = self.manna.harvest()

        st.metabolism.absorbEnergy(harvested)
        st.metabolism.inhale()
        MannaCoordinator.shared.beEaten(self.manna.sprite)
    }

    private func settleCombat() {
        guard let scr = scratch else { fatalError() }

        guard let (victor, victim) = scr.battle else { fatalError() }

        victor.dispatch.parasitize()
        victim.dispatch.apoptosize()
    }
}
