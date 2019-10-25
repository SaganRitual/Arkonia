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
        attributes: DispatchQueue.Attributes.concurrent,
        target: DispatchQueue.global()
    )

    static func lock<T>(
        _ execute: Dispatch.Lockable<T>.LockExecute? = nil,
        _ userOnComplete: Dispatch.Lockable<T>.LockOnComplete? = nil,
        _ completionMode: Dispatch.CompletionMode = .concurrent
    ) {
        func debugEx() -> [T]? { print("World.barrier"); defer { print("post-execute") }; return execute?() }
        func debugOc(_ args: [T]?) { print("World.\(completionMode)"); userOnComplete?(args) }

        Dispatch.Lockable<T>(lockQueue).lock(
            execute, userOnComplete, completionMode
        )
    }

    static func run(_ execute: @escaping () -> Void) {
        World.mainQueue.async(execute: execute)
    }

    static func runAfter(
        deadline: DispatchTime, _ execute: @escaping () -> Void
    ) {
        World.mainQueue.asyncAfter(deadline: deadline, execute: execute)
    }
}
