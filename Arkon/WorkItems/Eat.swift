import GameplayKit

final class Eat: Dispatchable {
    weak var dispatch: Dispatch!
    var runningAsBarrier: Bool { return dispatch.runningAsBarrier }
    var stepper: Stepper { return dispatch.stepper }

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func go() {
        dispatch.go({ self.aArrive() })
    }
}

extension Eat {
    func aArrive() {
        if (newGridlet?.contents ?? .nothing) == .nothing {
            return
        }

        touchFood_()
    }
}

extension Stepper {
    func battleArkon_(_ victimGridlet: Gridlet) {

        guard let otherSprite = victimGridlet.sprite,
            let otherUserData = otherSprite.userData,
            let otherAny = otherUserData[SpriteUserDataKey.stepper],
            let otherStepper = otherAny as? Stepper
        else { fatalError() }

        let order = (metabolism.mass_ > (otherStepper.metabolism.mass_ * 1.25)) ?
                    (self, otherStepper) : (otherStepper, self)

        settleCombat_(order.0, order.1)
    }

    func battleManna_(_ victimGridlet: Gridlet) {

        guard let otherSprite = victimGridlet.sprite,
            let otherUserData = otherSprite.userData,
            let otherAny = otherUserData[SpriteUserDataKey.manna],
            let manna = otherAny as? Manna
        else { fatalError() }

        eatManna(manna)
    }

    private func settleCombat_(_ victor: Stepper, _ victim: Stepper) {
        victor.parasitize(victim)
        victim.apoptosize()
    }
}

extension Stepper {
    private func eatManna(_ manna: Manna) {
        let harvested = manna.harvest()
        metabolism.absorbEnergy(harvested)
        metabolism.inhale()
        MannaCoordinator.shared.beEaten(manna.sprite)
    }

    private func touchFood_() {
        guard let victimGridlet = newGridlet else { fatalError() }

        switch victimGridlet.contents {
        case .arkon:   battleArkon_(victimGridlet)
        case .manna:   battleManna_(victimGridlet)
        default: fatalError()
        }
    }
}
