import SpriteKit

final class Eat: AKWorkItem {
    enum Phase { case chooseEdible, settleCombat }

    var combatOrder: (Stepper, Stepper)?
    var currentGridlet: Gridlet!
    var manna: Manna!
    var phase = Phase.chooseEdible

    override init(_ dispatch: Dispatch) {
        super.init(dispatch)
        runType = .concurrent
    }

    deinit {
//        print("~Eat()")
        dispatch?.gridletEngager = nil
    }

    func callAgain(_ phase: Phase, _ runType: Dispatch.RunType) {
        self.phase = phase
        self.runType = runType
        dispatch!.callAgain()
    }

    override func go() { aEat() }

    func inject(_ manna: Manna) {
        self.manna = manna
        self.phase = .settleCombat
    }
}

extension Eat {
    private func aEat() {
        switch phase {
        case .chooseEdible:

            switch dispatch?.gridletEngager.gridletTo?.contents {
            case .arkon:
                print(
                    "battle " +
                    "\((dispatch?.gridletEngager.gridletFrom?.sprite?.name)!) " +
                    "\((dispatch?.gridletEngager.gridletFrom?.contents)!) " +
                    "\((dispatch?.gridletEngager.gridletFrom?.gridPosition)!) " +
                    "\((dispatch?.gridletEngager.gridletTo?.sprite?.name)!)" +
                    "\((dispatch?.gridletEngager.gridletTo?.contents)!)" +
                    "\((dispatch?.gridletEngager.gridletTo?.gridPosition)!) "
                )
                battleArkon()
                callAgain(.settleCombat, .barrier)

            case .manna:
                battleManna()
                callAgain(.settleCombat, .barrier)

            default: fatalError()
            }

        case .settleCombat:
            switch dispatch?.gridletEngager.gridletTo?.contents {

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

        guard let toCopy = dispatch?.gridletEngager.gridletTo else { fatalError() }
//        let toActual = Gridlet.at(toCopy.gridPosition)

        guard let victimSprite = toCopy.sprite
            else { print("nothing at \(toCopy.gridPosition)"); fatalError() }

        guard let victimStepper = Stepper.getStepper(from: victimSprite)
            else { fatalError() }

        let myMass = dp.stepper.metabolism.mass
        let hisMass = victimStepper.metabolism.mass
        print("combat: \(dp.stepper.name) \(myMass) <-> \(hisMass) \(victimStepper.name)")

        victimStepper.dispatch.battle = (myMass > (hisMass * 1.25)) ?
            (dp.stepper, victimStepper) : (victimStepper, dp.stepper)

        dp.gridletEngager.deinit_(dp)
    }

    func battleManna() {

        guard let mannaSprite = dispatch?.gridletEngager.gridletTo?.sprite,
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
        assert(runType == .barrier)
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
