import Dispatch

enum Sync {
    enum CompletionMode { case continueBarrier, concurrent }

    class Lockable<T> {
        let dispatchQueue: DispatchQueue

        init(_ dispatchQueue: DispatchQueue = World.mainQueue) {
            self.dispatchQueue = dispatchQueue
        }

        func lock(
            _ execute: LockExecute? = nil,
            _ userOnComplete: LockOnComplete? = nil,
            _ completionMode: CompletionMode = .concurrent
        ) {
            dispatchQueue.async(flags: .barrier) {
                let result: [T]?

                if let ex = execute { result = ex() }
                else { result = nil }

                self.scheduleCompletion(
                    onComplete: userOnComplete,
                    args: result,
                    completionMode: completionMode
                )
            }
        }

        private func scheduleCompletion(
            onComplete: LockOnComplete? = nil,
            args: [T]? = nil,
            completionMode: CompletionMode = .concurrent
        ) {
            guard let oc = onComplete else { return }

            switch completionMode {
            case .continueBarrier: oc(args)
            case .concurrent:      World.run { oc(args) }
            }
        }
    }
}

extension Sync.Lockable {
    typealias LockExecute = () -> [T]?
    typealias LockOnComplete = ([T]?) -> Void
}
