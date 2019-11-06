import SpriteKit

final class Eat: AKWorkItem {
    enum Phase { case chooseEdible, settleCombat }

    var combatOrder: (Stepper, Stepper)?
    var currentGridlet: Gridlet!
    var manna: Manna!
    var phase = Phase.chooseEdible
    var shiftTracker = ShiftTracker()

    func callAgain(_ phase: Phase, _ runType: Dispatch.RunType) {
        self.phase = phase
        self.runType = runType
        dispatch!.callAgain()
    }

    override func go() { aEat() }

    func inject(_ shiftTracker: ShiftTracker) {
        self.shiftTracker = shiftTracker
    }

    func inject(_ combatOrder: (Stepper, Stepper)?) {
        self.combatOrder = combatOrder
        self.phase = .settleCombat
    }

    func inject(_ manna: Manna) {
        self.manna = manna
        self.phase = .settleCombat
    }
}

extension Eat {
    //swiftmint:disable function_body_length
    private func aEat() {
        switch phase {
        case .chooseEdible:

            if let bms = shiftTracker.beforeMoveStop {
                print("st0", stepper?.name ?? "<no stepper?>", bms.contents,
                      (bms.sprite?.userData?[SpriteUserDataKey.stepper] as? Stepper)?.name ?? "<no target sprite>")
            } else {
                print("st1")
            }
            switch shiftTracker.beforeMoveStop?.contents {
            case .arkon:
                battleArkon()
                callAgain(.settleCombat, .barrier)

            case .manna:
                battleManna()
                callAgain(.settleCombat, .barrier)

            default: fatalError()
            }

        case .settleCombat:
//            print("st2", st.gridlet.contents, st.gridlet.gridPosition)
            switch shiftTracker.beforeMoveStop?.contents {
            case .arkon:
                settleCombat()

            case .manna:
                defeatManna()
                dispatch?.funge()

            default: fatalError()
            }
        }
    }
    //swiftmint:enable function_body_length
}

extension Eat {
    func battleArkon() {
        guard let dp = dispatch else { fatalError() }

        guard let victim = shiftTracker.beforeMoveStop,
            let victimSprite = victim.sprite,
            let victimUserData = victimSprite.userData,
            let victimAny = victimUserData[SpriteUserDataKey.stepper],
            let victimStepper = victimAny as? Stepper
        else { fatalError() }

//        otherGridlet.releaseGridlet()

        let myMass = dp.stepper.metabolism.mass
        let hisMass = victimStepper.metabolism.mass
        print("combat: \(dp.stepper.name) \(myMass) <-> \(hisMass) \(victimStepper.name)")

        self.combatOrder =
            (myMass > (hisMass * 1.25)) ? (dp.stepper, victimStepper) : nil
    }

    func getResult() -> (Stepper, Stepper)? {
        return combatOrder
    }

    func battleManna() {

        guard let mannaSprite = shiftTracker.beforeMoveStop?.sprite,
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
        assert(runType == .barrier)
        guard let co = self.combatOrder else {
            dispatch?.apoptosize()
            return
        }

        print("sc1", co.0.name, co.1.name)
        co.0.dispatch.parasitize()
        print("sc2", co.0.name, co.1.name)
        co.1.dispatch.apoptosize()
        print("sc3", co.0.name, co.1.name)
        co.0.gridlet.disengageGridlet(runType)
    }
}
