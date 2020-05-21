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

    // In case my ring buffer buys us any performance over a plain array
    private var workItems = Cbuffer<() -> Void>(cElements: 1000)

    func schedule(_ workItem: @escaping () -> Void) {
        lockQueue.async { self.workItems.push(workItem) }
    }

    var maxWorkItemsTime = UInt64(0)
    var overdueCount = 0

    func tick() {
        lockQueue.sync {
            hardAssert(Display.displayCycle == .updateStarted)

            let start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
            var duration = UInt64(0)

            while !workItems.isEmpty {
                let workItem = workItems.pop()
                workItem()

                duration = clock_gettime_nsec_np(CLOCK_UPTIME_RAW) - start
                if duration > maxWorkItemsTime {
                    if overdueCount > 5 {
                        overdueCount = 0
                        maxWorkItemsTime += Arkonia.one_ms
                        Debug.log(level: 173) { "Increasing scene dispatch queue time limit to \(maxWorkItemsTime / Arkonia.one_ms) ms" }
                    }

                    break
                }
            }

            if workItems.isEmpty { overdueCount = 0 } else { overdueCount += 1 }

            if duration < maxWorkItemsTime && maxWorkItemsTime > Arkonia.one_ms && overdueCount == 0 {
                maxWorkItemsTime -= Arkonia.one_ms / UInt64(10)
                Debug.log(level: 173) { "Decreasing scene dispatch queue time limit to \(maxWorkItemsTime / Arkonia.one_ms) ms" }
            }

            if workItems.count > Int(CGFloat(workItems.cElements) * 0.9) {
                Debug.log { "SceneDispatch workitems.count = \(workItems.count)" }
            }
        }
    }
}
