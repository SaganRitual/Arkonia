import Dispatch

enum Dispatch {
    enum CompletionMode { case continueBarrier, concurrent }

    class Lockable<T> {
        let dispatchQueue: DispatchQueue

        init(_ dispatchQueue: DispatchQueue = Grid.lockQueue) {
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
                    completionMode: .continueBarrier
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
            case .concurrent:      World.run({
                let k: String
                if let kk = args { k = String(describing: kk) } else { k = "<nil>" }
                print("oc1", k)
                oc(args)
                print("oc2")
            })
            }
        }
    }
}

extension Dispatch.Lockable {
    typealias LockExecute = () -> [T]?
    typealias LockOnComplete = ([T]?) -> Void
}
