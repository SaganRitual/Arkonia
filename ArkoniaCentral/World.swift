import SpriteKit

class World {
    static let mutator = Mutator()
    static let shared = World()

    private let timeLimit: TimeInterval? = 10000

    let concurrentQueue = DispatchQueue(
        label: "arkonia.concurrent.queue",
        qos: .utility, attributes: .concurrent,
        target: DispatchQueue.global(qos: .background)
    )
}
