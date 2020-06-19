import SpriteKit

class GridDebugSprite {
    enum State {
        case pristine, centerLock, locked, blind, deferred
        case unlocked, deferredAndCompleted
        case reservedForOffspring, reservedForMiracleBirth
    }

    var previousColor: SKColor = .darkGray
    var currentColor: SKColor = .darkGray
    var state = State.pristine
    let sprite: SKSpriteNode

    init(_ sprite: SKSpriteNode) {
        self.sprite = sprite
        currentColor = .darkGray
    }

    func runActions() {
        let actionForPrevious = SKAction.colorize(with: previousColor, colorBlendFactor: 1, duration: 0.25)
        let actionForCurrent  = SKAction.colorize(with: currentColor, colorBlendFactor: 1, duration: 0.25)
        let sequence = SKAction.sequence([actionForPrevious, actionForCurrent])
        let forever = SKAction.repeatForever(sequence)

        sprite.removeAllActions()
        sprite.run(forever)
    }

    func showLock(_ newState: State) {
        previousColor = currentColor

        switch newState {
        case .reservedForOffspring:    currentColor = .green
        case .reservedForMiracleBirth: currentColor = .magenta
        case .deferredAndCompleted:    currentColor = .magenta

        case .centerLock: currentColor = .yellow
        case .deferred:   currentColor = .blue
        case .locked:     currentColor = .red
        case .blind:      currentColor = .black
        case .unlocked:   currentColor = .darkGray
        default:          currentColor = .darkGray
        }

        state = newState
        runActions()
    }
}
