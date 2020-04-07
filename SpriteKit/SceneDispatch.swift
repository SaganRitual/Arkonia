import Dispatch
import Foundation

/**
 Executes work items in the scene's update context

 I think a couple of the access faults we're seeing are due to our multi-threaded
 access of the sprites and actions and stuff. This lets us schedule stuff to
 run on the next scene update, on the main thread
*/
enum SceneDispatch {
    private static let lockQueue = DispatchQueue(
        label: "ak.scene.q", target: DispatchQueue.global(qos: .default)
    )

    private static var workItems = [() -> Void]()

    static func schedule(_ workItem: @escaping () -> Void) {
        lockQueue.async {
            cWorkItems += 1
            workItems.append(workItem)
        }
    }

    static var highWaterWorkItems = 0
    static var cWorkItems = 0

    static func tick() {
        let tickStartTime = Date()

        lockQueue.sync {

            defer {
                if cWorkItems > highWaterWorkItems {
                    Debug.log { "SceneDispatch cWorkItems = \(cWorkItems)" }
                    highWaterWorkItems = cWorkItems
                }
            }

            while let wi = workItems.popFirst() {
                cWorkItems -= 1
                wi()

                if Date().timeIntervalSince(tickStartTime) > 0.01 {
                    return
                }
            }
        }
    }
}
