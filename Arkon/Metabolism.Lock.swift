import CoreGraphics
import Dispatch

extension Metabolism {
    func getMass(_ onComplete: @escaping (CGFloat) -> Void) {
        Lock.lockQueue.async(flags: .barrier) { [unowned self] in
            onComplete(self.mass_)
        }
    }

    func setMass(
        to newMass: CGFloat, _ onComplete: (() -> Void)? = nil
    ) {
        Lock.lockQueue.async(flags: .barrier) { [unowned self] in
            self.mass_ = newMass
            onComplete?()
        }
    }

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
}
