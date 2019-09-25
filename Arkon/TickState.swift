import GameplayKit
import SpriteKit

protocol TickStateProtocol: GKState {
    var core: Arkon { get }
    var metabolism: Metabolism { get }
    var sprite: SKSpriteNode { get }
    var statum: TickStatum! { get set }
    var stepper: Stepper { get }
    func inject(_ statum: TickStatum)
}

extension TickStateProtocol {
    var core: Arkon { return stepper.core }
    var metabolism: Metabolism { return stepper.metabolism }
    var sprite: SKSpriteNode { return stepper.sprite }
    var stepper: Stepper { return statum.stepper }

    func inject(_ statum: TickStatum) {
        self.statum = statum
    }
}

class TickStatum {
    var shiftTarget = AKPoint.zero
    let sm: GKStateMachine
    let states: [TickStateProtocol]
    weak var stepper: Stepper!

    init(stepper: Stepper) {
        self.stepper = stepper

        let states: [TickStateProtocol] = [
            TickState.Apoptosize(), TickState.Colorize(), TickState.Dead(),
            TickState.Metabolize(), TickState.Shift(), TickState.Shiftable(),
            TickState.Spawnable(), TickState.Start()
        ]

        // Start (funge)
        // Spawnable
        // Colorize
        // Metabolize?
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
            let ef = metabolism.fungibleEnergyFullness
            core.nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

            let baseColor: Int
            if core.selectoid.fishNumber < 10 {
                baseColor = 0xFF_00_00
            } else {
                baseColor = (metabolism.spawnEnergyFullness > 0) ?
                    Arkon.brightColor : Arkon.standardColor
            }

            let four: CGFloat = 4
            sprite.color = ColorGradient.makeColorMixRedBlue(
                baseColor: baseColor,
                redPercentage: metabolism.spawnEnergyFullness,
                bluePercentage: max((four - CGFloat(core.age)) / four, 0.0)
            )

            sprite.colorBlendFactor = metabolism.oxygenLevel
        }
    }

    class Dead: GKState, TickStateProtocol {
        var statum: TickStatum!
        override func didEnter(from previousState: GKState?) {
            fatalError("Shouldn't get this far; should all be done at apoptosize()")
        }
    }

    class MetabolizePending: GKState, TickStateProtocol {
        var statum: TickStatum!
    }

    class Metabolize: GKState, TickStateProtocol {
        var statum: TickStatum!

        override func update(deltaTime seconds: TimeInterval) {
            stateMachine?.enter(TickState.MetabolizePending.self)
            metabolize()
            stateMachine?.enter(TickState.Colorize.self)
        }

        func metabolize() {
            metabolism.tick()
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
            let currentPosition = stepper.gridlet.gridPosition
            let newGridlet = Gridlet.at(currentPosition + statum.shiftTarget)

            let goStep = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)

            let goContents = SKAction.run { [weak self] in
                guard let myself = self else { fatalError() }

                defer {
                    myself.stepper.gridlet.sprite = nil
                    myself.stepper.gridlet.contents = .nothing

                    newGridlet.contents = .arkon
                    newGridlet.sprite = myself.sprite

                    myself.stepper.gridlet = newGridlet
                }

               myself.touchFood(eater: myself.stepper, foodLocation: newGridlet)
            }

            let goSequence = SKAction.sequence([goStep, goContents])
            sprite.run(goSequence) {
                self.stateMachine?.enter(TickState.Start.self)
            }
        }

        func touchFood(eater: Stepper, foodLocation: Gridlet) {

            var userDataKey = SpriteUserDataKey.karamba

            switch foodLocation.contents {
            case .arkon:
                userDataKey = .stepper

                if let otherSprite = foodLocation.sprite,
                    let otherUserData = otherSprite.userData,
                    let otherAny = otherUserData[userDataKey],
                    let otherStepper = otherAny as? Stepper
                {
                    eater.touchArkon(otherStepper)
                }

            case .manna:
                userDataKey = .manna

                if let otherSprite = foodLocation.sprite,
                    let otherUserData = otherSprite.userData,
                    let otherAny = otherUserData[userDataKey],
                    let manna = otherAny as? Manna
                {
                    eater.touchManna(manna)
                }

            case .nothing: break
            }

        }
    }

    class ShiftablePending: GKState, TickStateProtocol {
        var statum: TickStatum!
    }

    class Shiftable: GKState, TickStateProtocol {
        var statum: TickStatum!

        override func update(deltaTime seconds: TimeInterval) {
            stateMachine?.enter(TickState.ShiftablePending.self)

            let shiftable = calculateShift()

            stateMachine?.enter(
                shiftable ? TickState.Shift.self : TickState.Start.self
            )
        }

        func calculateShift() -> Bool {
            let senseData = stepper.loadSenseData()
            statum.shiftTarget = stepper.selectMoveTarget(senseData)

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
            stateMachine?.enter(TickState.Colorize.self)
        }

        func attemptSpawn() {
            // 10% entropy
            let spawnCost = EnergyReserve.startingEnergyLevel * 1.10

    //        print("msrv", metabolism.spawnReserves.level, spawnCost)
            if metabolism.spawnReserves.level >= spawnCost {
                metabolism.withdrawFromSpawn(spawnCost)

                let biases = core.net.biases
                let weights = core.net.weights
                let layers = core.net.layers
                let waitAction = SKAction.wait(forDuration: 0.02)
                let spawnAction = SKAction.run {
                    Stepper.spawn(parentBiases: biases, parentWeights: weights, layers: layers)
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
            let fudgeFactor: CGFloat = 0.2
            let targetSpeed: CGFloat = 0.1 * 1000  // some random # * 1000 pixels/sec
            let joulesNeeded = fudgeFactor * abs(targetSpeed) * metabolism.mass

            metabolism.withdrawFromReady(joulesNeeded)

            let oxygenCost: TimeInterval = core.age < TimeInterval(5) ? 0 : 1
            metabolism.oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

            return metabolism.fungibleEnergyFullness > 0 && metabolism.oxygenLevel > 0
        }
    }
}
