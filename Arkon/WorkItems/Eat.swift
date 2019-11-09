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

    func inject(_ manna: Manna) {
        self.manna = manna
        self.phase = .settleCombat
    }
}

extension Eat {
    private func aEat() {
        switch phase {
        case .chooseEdible:

            switch shiftTracker.beforeMoveStop?.contents {
            case .arkon:
                battleArkon()
                return

            case .manna:
                battleManna()
                callAgain(.settleCombat, .barrier)

            default: fatalError()
            }

        case .settleCombat:
            switch shiftTracker.beforeMoveStop?.contents {

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

        guard let victim = shiftTracker.beforeMoveStop,
            let victimSprite = victim.sprite,
            let victimUserData = victimSprite.userData,
            let victimAny = victimUserData[SpriteUserDataKey.stepper],
            let victimStepper = victimAny as? Stepper
        else { fatalError() }

        let myMass = dp.stepper.metabolism.mass
        let hisMass = victimStepper.metabolism.mass
        print("combat: \(dp.stepper.name) \(myMass) <-> \(hisMass) \(victimStepper.name)")

        victimStepper.dispatch.battle = (myMass > (hisMass * 1.25)) ?
            (dp.stepper, victimStepper) : (victimStepper, dp.stepper)
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
}
