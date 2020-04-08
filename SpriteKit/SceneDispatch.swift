import Dispatch
import Foundation

/**
 Executes work items in the scene's update context

 I think a couple of the access faults we're seeing are due to our multi-threaded
 access of the sprites and actions and stuff. This lets us schedule stuff to
 run on the next scene update, on the main thread
*/
class SceneDispatch {
    static let shared = SceneDispatch()

    private let lockQueue = DispatchQueue(
        label: "ak.scene.q",// attributes: .concurrent,
        target: DispatchQueue.global()
    )

    let fivems = UInt64(5e6)

    // In case my ring buffer buys us any performance over a plain array
    private var workItems = Cbuffer<() -> Void>(cElements: 1000)

    func schedule(_ workItem: @escaping () -> Void) {
        lockQueue.async { self.workItems.push(workItem) }
    }

    func tick() {
        lockQueue.sync {
            assert(Display.displayCycle == .updateStarted)

            let start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)

            while !workItems.isEmpty {
                let workItem = workItems.pop()
                workItem()

                if (clock_gettime_nsec_np(CLOCK_UPTIME_RAW) - start) > fivems { break }
            }
        }
    }
}
