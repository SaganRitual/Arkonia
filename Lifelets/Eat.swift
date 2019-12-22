import SpriteKit

final class Eat: Dispatchable {
    var manna: Manna!
    weak var scratch: Scratchpad?

    init(_ scratch: Scratchpad) {
//        Log.L.write("Eat \(six(scratch.stepper?.name))")
        self.scratch = scratch
    }

    deinit {
//        Log.L.write("!Eat \(six(scratch?.stepper?.name))")
    }

    func launch() {
//        Log.L.write("Eat.launch \(six(scratch?.stepper?.name))")
        chooseEdible()
    }
}

extension Eat {
    private func chooseEdible() {
//        Log.L.write("chooseEdible")
        guard let scr = scratch else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        switch gcc.to.contents {
        case .arkon: fatalError() //battleArkon()
        case .manna: battleManna()

        default: fatalError()
        }

        chooseBattle()
    }

    private func chooseBattle() {
//        Log.L.write("chooseBattle")
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
        guard let st = scr.stepper else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        guard let victimSprite = gcc.to.sprite else { fatalError() }

//        Log.L.write("battleArkon \(six(st.name)) attacks \(six(victimSprite.name))")

        guard let victimStepper = Stepper.getStepper(from: victimSprite)
            else { fatalError() }

        let myMass = st.metabolism.mass
        let hisMass = victimStepper.metabolism.mass

        scr.battle = (myMass > (hisMass * 1.25)) ? (st, victimStepper) : (victimStepper, st)
        victimStepper.dispatch.scratch.battle = scr.battle

        Log.L.write("battleArkon: \(six(scr.battle?.0.name)) eats \(six(scr.battle?.1.name))")
    }

    func battleManna() {
//        Log.L.write("battleManna")
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
//        Log.L.write("defeatManna")
        guard let scr = scratch else { fatalError() }
        guard let dp = scr.dispatch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }

        Grid.shared.concurrentQueue.sync(flags: .barrier) { [unowned self] in
            let harvested = self.manna.harvest()

            st.metabolism.absorbEnergy(harvested)
            st.metabolism.inhale()

            MannaCoordinator.shared.beEaten(self.manna.sprite)

            Log.L.write("clear gcc in defeat manna \(six(st.name))")
            scr.gridCellConnector = nil

            dp.currentTask = nil
            dp.funge()
        }
    }

    private func settleCombat() {
//        Log.L.write("settleCombat")
        guard let scr = scratch else { fatalError() }

        guard let (victor, victim) = scr.battle else { fatalError() }

        if victor.dispatch.scratch.gridCellConnector == nil {

            victor.dispatch.scratch.gridCellConnector =
                victim.dispatch.scratch.gridCellConnector

            victim.dispatch.scratch.gridCellConnector = nil

            guard let gcc = victor.dispatch.scratch.gridCellConnector as? SafeStage
                else { fatalError() }

            gcc.from.parasite = victor.name
            gcc.to.parasite =  victor.name
        }

//        Log.L.write("settleCombat: \(six(victor.name)) eats \(six(victim.name))")
        victor.dispatch.parasitize()
    }
}
