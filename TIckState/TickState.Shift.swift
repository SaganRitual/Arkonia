import GameplayKit

extension TickState {
    class ShiftPending: GKState, TickStateProtocol {
        var statum: TickStatum?
    }

    class Shift: GKState, TickStateProtocol {
        var statum: TickStatum?
    }

}

extension TickState.Shift {

    override func update(deltaTime seconds: TimeInterval) {
        let barrier = DispatchWorkItemFlags.barrier
        let gq = DispatchQueue.global()
        let qos = DispatchQoS.default

        let shiftLeave = DispatchWorkItem(qos: qos) { [weak self] in
//            print("gsh1", self?.core?.selectoid.fishNumber ?? -1)
            guard let myself = self else { return }
//            print("gsh2", self?.core?.selectoid.fishNumber ?? -1)

            myself.stateMachine?.enter(TickState.Start.self)
            myself.stateMachine?.update(deltaTime: 0)
        }

        let shiftWork = DispatchWorkItem(qos: qos) { [weak self] in
//            print("fsh1", self?.core?.selectoid.fishNumber ?? -1)
            guard let myself = self else { return }
//            print("fsh2", self?.core?.selectoid.fishNumber ?? -1)
            myself.shift()
            gq.async(execute: shiftLeave)
        }

        let shiftEnter = DispatchWorkItem(qos: qos, flags: barrier) {
//            print("esh", self.core?.selectoid.fishNumber ?? -1)
            _ = self.stateMachine?.enter(TickState.ShiftPending.self)
            gq.async(execute: shiftWork)
        }

        gq.async(execute: shiftEnter)
    }

    func shift() {
        let currentPosition = stepper?.gridlet.gridPosition ?? AKPoint.zero
        let newGridlet = Gridlet.at(currentPosition + (statum?.shiftTarget ?? AKPoint.zero))

        let goWait = SKAction.wait(forDuration: 1)
        let goStep = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)

        let goContents = SKAction.run { [weak self] in
            guard let myself = self else { fatalError() }
            guard let stepper = myself.stepper else { return }

            defer {
                myself.stepper?.gridlet.sprite = nil
                myself.stepper?.gridlet.contents = .nothing

                newGridlet.isEngaged = false
                newGridlet.contents = .arkon
                newGridlet.sprite = myself.sprite

                myself.stepper?.gridlet = newGridlet
            }

           myself.touchFood(foodLocation: newGridlet)
        }

        let goSequence = SKAction.sequence([goWait, goStep, goContents])
        sprite?.run(goSequence) {
            self.stateMachine?.enter(TickState.Start.self)
        }
    }

    func touchArkon(_ victimStepper: Stepper) {
        if (self.metabolism?.mass ?? 0) > (victimStepper.metabolism.mass * 1.25) {
            self.metabolism?.parasitize(victimStepper.metabolism)
            victimStepper.tickStatum?.sm.enter(TickState.Apoptosize.self)
        } else {
            if let m = self.metabolism {
                victimStepper.metabolism.parasitize(m)
            }

            self.stateMachine?.enter(TickState.Apoptosize.self)
        }
    }

    func touchFood(foodLocation: Gridlet) {

        var userDataKey = SpriteUserDataKey.karamba

        switch foodLocation.contents {
        case .arkon:
            userDataKey = .stepper

            if let otherSprite = foodLocation.sprite,
                let otherUserData = otherSprite.userData,
                let otherAny = otherUserData[userDataKey],
                let otherStepper = otherAny as? Stepper
            {
                touchArkon(otherStepper)
            }

        case .manna:
            userDataKey = .manna

            if let otherSprite = foodLocation.sprite,
                let otherUserData = otherSprite.userData,
                let otherAny = otherUserData[userDataKey],
                let manna = otherAny as? Manna
            {
                touchManna(manna)
            }

        case .nothing: break
        }

    }

    func touchManna(_ manna: Manna) {
        // I guess I've died already?
        guard let background = self.sprite?.parent as? SKSpriteNode else { return }

        let sprite = manna.sprite

        let harvested = sprite.manna.harvest()
        metabolism?.absorbEnergy(harvested)
        metabolism?.inhale()

        let actions = Manna.triggerDeathCycle(sprite: sprite, background: background)
        sprite.run(actions)
    }
}
