import SpriteKit

final class Eat: Dispatchable {
    enum Phase { case chooseEdible, settleCombat }

    var combatOrder: (Stepper, Stepper)!
    weak var dispatch: Dispatch!
    var gridlet: Gridlet!
    var manna: Manna!
    var phase = Phase.chooseEdible
    var runningAsBarrier: Bool { return dispatch.runningAsBarrier }
    var stepper: Stepper { return dispatch.stepper }

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func go() {
        dispatch.go({ self.aEat() })
    }

    func inject(_ gridlet: Gridlet) { self.gridlet = gridlet }

    func inject(_ combatOrder: (Stepper, Stepper)) {
        self.combatOrder = combatOrder
        self.phase = .settleCombat
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

            switch dispatch.stepper.gridlet.contents {
            case .arkon:
                battleArkon()
                phase = .settleCombat
                dispatch.callAgain()

            case .manna:
                battleManna()
                phase = .settleCombat
                dispatch.defeatManna()

            default: fatalError()
            }

        case .settleCombat:
            switch dispatch.stepper.gridlet.contents {
            case .arkon: settleCombat()
            case .manna: defeatManna()
                default: fatalError()
            }

            dispatch.funge()
        }
    }
}

extension Eat {
    func battleArkon() {
        assert(dispatch.runningAsBarrier == true)

        guard let otherSprite = dispatch.stepper.sprite,
            let otherUserData = otherSprite.userData,
            let otherAny = otherUserData[SpriteUserDataKey.stepper],
            let otherStepper = otherAny as? Stepper
        else { fatalError() }

        let myMass = dispatch.stepper.metabolism.mass
        let hisMass = otherStepper.metabolism.mass
        self.combatOrder = (myMass > (hisMass * 1.25)) ?
            (dispatch.stepper, otherStepper) : (otherStepper, dispatch.stepper)
    }

    func getResult() -> (Stepper, Stepper) {
        return combatOrder!
    }

    func battleManna() {

        guard let otherSprite = dispatch.stepper.sprite,
            let otherUserData = otherSprite.userData,
            let otherAny = otherUserData[SpriteUserDataKey.manna],
            let manna = otherAny as? Manna
        else { fatalError() }

        self.manna = manna
    }

    func getResult() -> Manna {
        return manna
    }
}

extension Eat {
    private func defeatManna() {
        let harvested = self.manna.harvest()
        stepper.metabolism.absorbEnergy(harvested)
        stepper.metabolism.inhale()
        MannaCoordinator.shared.beEaten(self.manna.sprite)
    }

    private func settleCombat() {
        self.combatOrder.0.dispatch.parasitize()
        self.combatOrder.1.dispatch.apoptosize()
    }
}
