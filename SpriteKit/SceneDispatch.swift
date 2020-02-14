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
        lockQueue.async { workItems.append(workItem) }
    }

    static func tick() {
        let startTime = Date()
        lockQueue.sync {
            if Date().timeIntervalSince(startTime) > 0.01 {
                return }
            while let wi = workItems.popFirst() { wi() }
        }
    }
}
