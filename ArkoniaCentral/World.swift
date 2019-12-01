import SpriteKit

class World {
    static let mutator = Mutator()
    static let shared = World()

    private let timeLimit: TimeInterval? = 10000
}
