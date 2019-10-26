import GameplayKit

typealias LockStepper = Dispatch.Lockable<Stepper>

extension Stepper {
    func arrive(_ targetOffset: AKPoint) {
        func workItem() -> [Void]? {
//            print("arrive start \(name)")
            arrive_(targetOffset); return nil }
        func onComplete(_ nothing: [Void]?) {
//            print("arrive complete -- funge \(name)")
            funge()
        }

        Grid.lock(workItem, onComplete, .concurrent)
    }

    private func arrive_(_ targetOffset: AKPoint) {
//        print("arrive_")
        defer { updateGridletContents_() }

        getStartStopGridlets_(targetOffset)

        if (newGridlet?.contents ?? .nothing) == .nothing {
            return
        }

        touchFood_()
    }

    private func getStartStopGridlets_(_ targetOffset: AKPoint) {
        gridlet.sprite = nil
        gridlet.contents = .nothing
        gridlet.gridletIsEngaged = false
        oldGridlet = gridlet

//        print("gssg \(gridlet.gridPosition) \(name)")

        let newGridPosition = gridlet.gridPosition + targetOffset
        newGridlet = Gridlet.at(newGridPosition)
    }
}

extension Stepper {
    func battleArkon_(_ victimGridlet: Gridlet) {

        guard let otherSprite = victimGridlet.sprite,
            let otherUserData = otherSprite.userData,
            let otherAny = otherUserData[SpriteUserDataKey.stepper],
            let otherStepper = otherAny as? Stepper
        else { fatalError() }

        let order = (metabolism.mass > (otherStepper.metabolism.mass * 1.25)) ?
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

    private func updateGridletContents_() {
        guard let ng = newGridlet else { fatalError() }

        ng.contents = .arkon
        ng.sprite = sprite
        gridlet = ng

        newGridlet = nil
        oldGridlet = nil
    }
}
