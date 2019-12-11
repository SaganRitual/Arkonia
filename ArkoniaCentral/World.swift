import SpriteKit

class World {
    static let mutator = Mutator()
    static let shared = World()

    let concurrentQueue = DispatchQueue(
        label: "arkonia.concurrent.queue",
        qos: .utility, attributes: .concurrent,
        target: DispatchQueue.global(qos: .background)
    )
}
