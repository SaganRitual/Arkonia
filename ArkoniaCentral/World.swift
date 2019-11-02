import SpriteKit

class World {
    static let mutator = Mutator()
    static let shared = World()

    private let timeLimit: TimeInterval? = 10000

    let mainQueue = DispatchQueue(
        label: "arkonia.main.asynq", qos: .default,
        attributes: DispatchQueue.Attributes.concurrent
    )

    let lockQueue = DispatchQueue(
        label: "arkonia.lock.world", qos: .default,
        attributes: DispatchQueue.Attributes.concurrent
    )
}
