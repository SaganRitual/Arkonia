import Foundation

final class Shifter: Dispatchable {
    weak var scratch: Scratchpad?
    var senseData = [Double]()
    var sensoryInputs = [(Double, Double)?]()

    var workItems = [DispatchWorkItem]()
    var workItemPostMove: DispatchWorkItem?
    var workItemMoveStepper: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch

        workItems = [
            DispatchWorkItem(flags: .init(), block: reserveGridPoints),
            DispatchWorkItem(flags: .init(), block: loadGridInputs),
            DispatchWorkItem(flags: .init(), block: calculateShift),
            DispatchWorkItem(flags: .init(), block: moveSprite)
        ]

        for ss in 1..<self.workItems.count {
            let finishedWorkItem = self.workItems[ss - 1]
            let newWorkItem = self.workItems[ss]

            finishedWorkItem.notify(queue: Grid.shared.concurrentQueue, execute: newWorkItem)
        }

        workItemMoveStepper = DispatchWorkItem(flags: .init(), block: moveStepper)
        workItemPostMove = DispatchWorkItem(flags: .init(), block: postMove)

        workItemMoveStepper!.notify(
            queue: Grid.shared.concurrentQueue, execute: workItemPostMove!
        )
    }

    func launch() { print("launch shifter")
        Grid.shared.concurrentQueue.async(execute: workItems[0]) }
}
