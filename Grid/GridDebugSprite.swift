import SpriteKit

class GridDebugSprite {
    enum State {
        case pristine, centerLock, locked, blind, deferred
        case unlocked, deferredAndCompleted
        case reservedForOffspring, reservedForMiracleBirth
    }

    let sprite: SKSpriteNode
    var currentState = State.pristine

    init(_ sprite: SKSpriteNode) { self.sprite = sprite }

    func setState(_ newState: State) {
        switch newState {
        case .locked:     setSimpleLock()
        case .unlocked:   setSlightlyWorn()
        case .deferred:   setDeferred()
        case .centerLock: setSimpleCenterLock()
        case .reservedForOffspring: setReservedForOffspring()
        case .reservedForMiracleBirth: setReservedForMiracleBirth()

        case .deferredAndCompleted: setSimpleLock()
        default: fatalError()
        }

        currentState = newState
    }

    func setDeferred() { sprite.color = .blue }
    func setReservedForMiracleBirth() { sprite.color = .magenta }
    func setReservedForOffspring() { sprite.color = .cyan }
    func setSimpleLock() { sprite.color = .red }
    func setSimpleCenterLock() { sprite.color = .yellow }
    func setSlightlyWorn() { sprite.color = .gray }
}
