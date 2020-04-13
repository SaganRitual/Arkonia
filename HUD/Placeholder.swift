import SpriteKit

// Dummy stuff to make it easy to place placeholders like it is to place
// reports and other hud stuff
class PlaceholderFactory {
    private let prototype: Placeholder

    init(hud: HUD) {
        prototype = (hud.getPlaceholderPrototype(.placeholder2a, from: hud.dashboards[1]) as? Placeholder)!
        hud.releasePrototype(prototype)
    }

    func newPlaceholder() -> Placeholder { return (prototype.copy() as? Placeholder)! }
}

final class Placeholder: SKSpriteNode {}
