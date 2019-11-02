import SpriteKit

class World {
    private let timeLimit: TimeInterval? = 10000
}

extension World {
    static let mutator = Mutator()
    static let shared = World()

    static let mainQueue = DispatchQueue(
        label: "arkonia.main.asynq", qos: .default,
        attributes: DispatchQueue.Attributes.concurrent
    )

    static let lockQueue = DispatchQueue(
        label: "arkonia.lock.world", qos: .default,
        attributes: DispatchQueue.Attributes.concurrent
    )
}
