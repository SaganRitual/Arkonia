import SpriteKit

final class Eat: AKWorkItem {
    enum Phase { case chooseEdible, settleCombat }

    var combatOrder: (Stepper, Stepper)?
    var manna: Manna!
    var phase = Phase.chooseEdible

    override init(_ dispatch: Dispatch) {
        super.init(dispatch)
        runType = .concurrent
    }

    deinit {
        dispatch?.gridCellConnector = nil
    }

    func callAgain(_ phase: Phase, _ runType: Dispatch.RunType) {
        self.phase = phase
        self.runType = runType
        dispatch!.callAgain()
    }

    override func go() {
        print("aEat \(six(stepper?.name))")
        aEat() }

    func inject(_ manna: Manna) {
        self.manna = manna
        self.phase = .settleCombat
    }
}

extension Eat {
    private func aEat() {
        guard let gcc = dispatch?.gridCellConnector as? SafeStage
            else { fatalError() }

        switch phase {
        case .chooseEdible:

            switch gcc.to.contents {
            case .arkon:
                battleArkon()
                callAgain(.settleCombat, .barrier)

            case .manna:
                battleManna()
                callAgain(.settleCombat, .barrier)

            default: fatalError()
            }

        case .settleCombat:
            switch gcc.to.contents {

            case .arkon:
                settleCombat()

            case .manna:
                defeatManna()
                dispatch?.funge()

            default: fatalError()
            }
        }
    }
}

extension Eat {
    func battleArkon() {
        guard let dp = dispatch else { fatalError() }
        guard let gcc = dp.gridCellConnector as? SafeStage else { fatalError() }

        guard let victimSprite = gcc.to.sprite
            else { print("nothing at \(gcc.to.gridPosition)"); fatalError() }

        guard let victimStepper = Stepper.getStepper(from: victimSprite)
            else { fatalError() }

        let myMass = dp.stepper.metabolism.mass
        let hisMass = victimStepper.metabolism.mass
        print("combat: \(dp.stepper.name) \(myMass) <-> \(hisMass) \(victimStepper.name)")

        victimStepper.dispatch.battle = (myMass > (hisMass * 1.25)) ?
            (dp.stepper, victimStepper) : (victimStepper, dp.stepper)

        dispatch?.battle = victimStepper.dispatch.battle
    }

    func battleManna() {
        guard let gcc = dispatch?.gridCellConnector as? SafeStage else { fatalError() }

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

        guard let st = stepper else { fatalError() }
        let harvested = self.manna.harvest()
        st.metabolism.absorbEnergy(harvested)
        st.metabolism.inhale()
        MannaCoordinator.shared.beEaten(self.manna.sprite)
    }

    private func settleCombat() {
        guard let (victor, victim) = dispatch?.battle else { fatalError() }

        victor.dispatch.parasitize(victim)
        victim.dispatch.apoptosize()
    }
}
