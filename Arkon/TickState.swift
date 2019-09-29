import GameplayKit
import SpriteKit

protocol TickStateProtocol: GKState {
    var core: Arkon { get }
    var metabolism: Metabolism? { get }
    var sprite: SKSpriteNode { get }
    var statum: TickStatum! { get set }
    var stepper: Stepper? { get }
    func inject(_ statum: TickStatum)
}

extension TickStateProtocol {
    var core: Arkon { return stepper!.core }
    var metabolism: Metabolism? { return stepper?.metabolism }
    var sprite: SKSpriteNode { return stepper!.sprite }
    var stepper: Stepper? { return statum.stepper }

    func inject(_ statum: TickStatum) {
        self.statum = statum
    }
}

class TickStatum {
    var shiftTarget = AKPoint.zero
    let sm: GKStateMachine
    let states: [TickStateProtocol]
    weak var stepper: Stepper?

    init(stepper: Stepper) {
        self.stepper = stepper

        let states: [TickStateProtocol] = [
            TickState.Apoptosize(), TickState.Colorize(), TickState.Dead(),
            TickState.Metabolize(), TickState.Shift(), TickState.Shiftable(),
            TickState.Spawnable(), TickState.Start()
        ]

        // Start (funge)
        // Spawnable
        // Metabolize?
        // Colorize
        // Shiftable
        // Shift
        // Apoptosize
        // Dead

        sm = GKStateMachine(states: states)
        self.states = states

        states.forEach { $0.inject(self) }

        sm.enter(TickState.Start.self)
    }
}

enum TickState {

    class ApoptosizePending: GKState, TickStateProtocol {
        var statum: TickStatum!
    }

    class Apoptosize: GKState, TickStateProtocol {
        var statum: TickStatum!

        func apoptosize() {
            let action = SKAction.run { [weak self] in
                self?.core.apoptosize()
                self?.stateMachine?.enter(TickState.Dead.self)
            }

            sprite.run(action)
        }

        override func didEnter(from previousState: GKState?) {
            sprite.removeAllActions()
        }

        override func update(deltaTime seconds: TimeInterval) {
            stateMachine?.enter(TickState.ApoptosizePending.self)
            apoptosize()
        }
    }

    class ColorizePending: GKState, TickStateProtocol {
        var statum: TickStatum!
    }

    class Colorize: GKState, TickStateProtocol {
        var statum: TickStatum!

        override func update(deltaTime seconds: TimeInterval) {
            stateMachine?.enter(TickState.ColorizePending.self)
            colorize()
            stateMachine?.enter(TickState.Shiftable.self)
        }

        func colorize() {
            let ef = metabolism?.fungibleEnergyFullness ?? 0
            core.nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

            let baseColor: Int
            if core.selectoid.fishNumber < 10 {
                baseColor = 0xFF_00_00
            } else {
                baseColor = ((metabolism?.spawnEnergyFullness ?? 0) > 0) ?
                    Arkon.brightColor : Arkon.standardColor
            }

            let four: CGFloat = 4
            sprite.color = ColorGradient.makeColorMixRedBlue(
                baseColor: baseColor,
                redPercentage: metabolism?.spawnEnergyFullness ?? 0,
                bluePercentage: max((four - CGFloat(core.age)) / four, 0.0)
            )

            sprite.colorBlendFactor = metabolism?.oxygenLevel ?? 0
        }
    }

    class Dead: GKState, TickStateProtocol {
        var statum: TickStatum!
//        override func didEnter(from previousState: GKState?) {
//            fatalError("Shouldn't get this far; should all be done at apoptosize()")
//        }
    }

    class MetabolizePending: GKState, TickStateProtocol {
        var statum: TickStatum!
    }

    class Metabolize: GKState, TickStateProtocol {
        var statum: TickStatum!

        override func update(deltaTime seconds: TimeInterval) {
            stateMachine?.enter(TickState.MetabolizePending.self)
            metabolize()
        }

        func metabolize() {
            let action = SKAction.run({ [weak self] in
                self?.metabolism?.tick()
                self?.stateMachine?.enter(TickState.Colorize.self)
            }, queue: self.core.netQueue)

            sprite.run(action)
        }
    }

    class ShiftPending: GKState, TickStateProtocol {
        var statum: TickStatum!
    }

    class Shift: GKState, TickStateProtocol {
        var statum: TickStatum!

        override func update(deltaTime seconds: TimeInterval) {
            stateMachine?.enter(TickState.ShiftPending.self)
            shift()
        }

        func shift() {
            let currentPosition = stepper?.gridlet.gridPosition ?? AKPoint.zero
            let newGridlet = Gridlet.at(currentPosition + statum.shiftTarget)

            let goStep = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)

            let goContents = SKAction.run { [weak self] in
                guard let myself = self else { fatalError() }
                guard let stepper = myself.stepper else { return }

                defer {
                    myself.stepper?.gridlet.sprite = nil
                    myself.stepper?.gridlet.contents = .nothing

                    newGridlet.contents = .arkon
                    newGridlet.sprite = myself.sprite

                    myself.stepper?.gridlet = newGridlet
                }

               myself.touchFood(foodLocation: newGridlet)
            }

            let goSequence = SKAction.sequence([goStep, goContents])
            sprite.run(goSequence) {
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
            guard let background = self.sprite.parent as? SKSpriteNode else { return }

            let sprite = manna.sprite

            let harvested = sprite.manna.harvest()
            metabolism?.absorbEnergy(harvested)
            metabolism?.inhale()

            let actions = Manna.triggerDeathCycle(sprite: sprite, background: background)
            sprite.run(actions)
        }
    }

    class ShiftablePending: GKState, TickStateProtocol {
        var statum: TickStatum!
    }

    class Shiftable: GKState, TickStateProtocol {
        var statum: TickStatum!

        override func update(deltaTime seconds: TimeInterval) {
            stateMachine?.enter(TickState.ShiftablePending.self)

            let action = SKAction.run({ [weak self] in
                let shiftable = self?.calculateShift() ?? false

                self?.stateMachine?.enter(
                    shiftable ? TickState.Shift.self : TickState.Start.self
                )
            }, queue: self.core.netQueue)

            sprite.run(action)
        }

        func calculateShift() -> Bool {
            guard let s = self.stepper else { return false }
            let senseData = s.loadSenseData()
            statum.shiftTarget = s.selectMoveTarget(senseData)

            return statum.shiftTarget != AKPoint.zero
        }
    }

    class SpawnablePending: GKState, TickStateProtocol {
        var statum: TickStatum!
    }

    class Spawnable: GKState, TickStateProtocol {
        var statum: TickStatum!

        override func update(deltaTime seconds: TimeInterval) {
            stateMachine?.enter(TickState.SpawnablePending.self)
            attemptSpawn()
            stateMachine?.enter(TickState.Metabolize.self)
        }

        func attemptSpawn() {
            // 10% entropy
            let spawnCost = EnergyReserve.startingEnergyLevel * 1.0

//            print("msrv", metabolism.spawnReserves.level, spawnCost)
            if (metabolism?.spawnReserves.level ?? 0) >= spawnCost {
                metabolism?.withdrawFromSpawn(spawnCost)

                let activator = core.net.activatorFunction
                let biases = core.net.biases
                let weights = core.net.weights
                let layers = core.net.layers
                let waitAction = SKAction.run {}// SKAction.wait(forDuration: 0.02)
                let spawnAction = SKAction.run {
                    Stepper.spawn(
                        parentBiases: biases, parentWeights: weights,
                        layers: layers, parentActivator: activator
                    )
                }

                let sequence = SKAction.sequence([waitAction, spawnAction])
                Arkon.arkonsPortal!.run(sequence) {
                    self.core.selectoid.cOffspring += 1
                    World.shared.registerCOffspring(self.core.selectoid.cOffspring)
                }

            }
        }
    }

    class StartPending: GKState, TickStateProtocol {
        var statum: TickStatum!
    }

    class Start: GKState, TickStateProtocol {
        var statum: TickStatum!

        override func update(deltaTime seconds: TimeInterval) {
            stateMachine?.enter(TickState.StartPending.self)

            let alive = funge()

            stateMachine?.enter(
                alive ? TickState.Spawnable.self : TickState.Apoptosize.self
            )
        }

        func funge() -> Bool {
            let fudgeFactor: CGFloat = 1
            let joulesNeeded = fudgeFactor * (metabolism?.mass ?? 0)

            metabolism?.withdrawFromReady(joulesNeeded)

            let oxygenCost: TimeInterval = core.age < TimeInterval(5) ? 0 : 1
            metabolism?.oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

            return (metabolism?.fungibleEnergyFullness ?? 0) > 0 &&
                    (metabolism?.oxygenLevel ?? 0) > 0
        }
    }
}
