import GameplayKit
import SpriteKit

protocol TickStateProtocol: GKState {
    var core: Arkon? { get }
    var metabolism: Metabolism? { get }
    var sprite: SKSpriteNode? { get }
    var statum: TickStatum? { get set }
    var stepper: Stepper? { get }
    func inject(_ statum: TickStatum)
}

extension TickStateProtocol {
    var core: Arkon? { return stepper?.core }
    var metabolism: Metabolism? { return stepper?.metabolism }
    var sprite: SKSpriteNode? { return stepper?.sprite }
    var stepper: Stepper? { return statum?.stepper }

    func inject(_ statum: TickStatum) {
        self.statum = statum
    }
}

class TickStatum {
    var shiftTarget = AKPoint.zero
    let sm: GKStateMachine
    var isStarted = false
    let states: [TickStateProtocol]
    weak var stepper: Stepper?

    init(stepper: Stepper) {
        self.stepper = stepper

        let states: [TickStateProtocol] = [
            TickState.Apoptosize(), TickState.Colorize(), TickState.Dead(),
            TickState.Metabolize(), TickState.Shift(), TickState.Shiftable(),
            TickState.Spawnable(), TickState.Start()
        ]

        sm = GKStateMachine(states: states)
        self.states = states

        states.forEach { $0.inject(self) }

        sm.enter(TickState.Start.self)
        sm.update(deltaTime: 0)
    }
}

enum TickState {
    class Dead: GKState, TickStateProtocol {
        var statum: TickStatum?
    }
}

extension TickState.Dead {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}
