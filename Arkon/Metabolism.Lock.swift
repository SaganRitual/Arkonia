import CoreGraphics
import Dispatch

extension Metabolism {
//    func getMass(_ onComplete: @escaping (CGFloat) -> Void) {
//        Lock.lockQueue.async(flags: .barrier) { [unowned self] in
//            onComplete(self.mass)
//        }
//    }

//    func setMass(
//        to newMass: CGFloat, _ onComplete: (() -> Void)? = nil
//    ) {
//        assert(false)
//        Lock.lockQueue.async(flags: .barrier) { [unowned self] in
//            self.mass = newMass
//            onComplete?()
//        }
//    }

    class Lock {
        static fileprivate let lockQueue = DispatchQueue(
            label: "arkon.lock.metabolism", qos: .userInteractive,
            attributes: DispatchQueue.Attributes.concurrent,
            target: DispatchQueue.global()
        )

        weak var metabolism: Metabolism?

        init(_ metabolism: Metabolism) {
            self.metabolism = metabolism
        }
    }
}

extension Metabolism.Lock {
    static func lock<T>(
        _ execute: Sync.Lockable<T>.LockExecute? = nil,
        _ userOnComplete: Sync.Lockable<T>.LockOnComplete? = nil,
        _ completionMode: Sync.CompletionMode = .concurrent
    ) {
        func debugEx() -> [T]? { print("World.barrier"); defer { print("post-execute") }; return execute?() }
        func debugOc(_ args: [T]?) { print("World.\(completionMode)"); userOnComplete?(args) }

        Sync.Lockable<T>(lockQueue).lock(
            execute, userOnComplete, completionMode
        )
    }
}
