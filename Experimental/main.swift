//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
  
import Dispatch
import Foundation

#if EXPERIMENTAL
print("Experimental")
#endif

#if RUN_DARK
print("Run dark")
#endif

let f = TSNumberGuesserFactory()
let c = Curator(tsFactory: f)
let x = c.select()

#if THIS_WORKS_WITH_MY_GLOBAL_AND_MY_SLEEP_NOT_HIS_MAIN
let group = DispatchGroup()
let queue = DispatchQueue.global()
//let queue = DispatchQueue(label: "com.theswiftdev.queues.serial")
let workItem = DispatchWorkItem {
    print("start")
//    sleep(1)
    print("end")
}

queue.async(group: group) {
    print("group start")
//    sleep(2)
    print("group end")
}

queue.async(group: group) { print("fuck this too!") }
queue.async(group: group, execute: workItem)

// you can block your current queue and wait until the group is ready
// a better way is to use a notification block instead of blocking
//group.wait(timeout: .now() + .seconds(3))
//print("done")

group.notify(queue: queue) {
    print("done")
}
sleep(1)

#endif

#if ANOTHER_THAT_WORKS_WITH_GLOBAL
func load(delay: UInt32, completion: () -> Void) {
    sleep(delay)
    completion()
}

let group = DispatchGroup()

group.enter()
load(delay: 1) {
    print("1")
    group.leave()
}

group.enter()
load(delay: 1) {
    print("2")
    group.leave()
}

group.enter()
load(delay: 1) {
    print("3")
    group.leave()
}

group.notify(queue: .global()) {
    print("done")
}
#endif

//let q = DispatchQueue.global()

//q.async {
//    print("this will return instantly")
//}
//
//let text = q.sync {
//    return "this will block"
//}
//print(text)


//var workItem: DispatchWorkItem?
//workItem = DispatchWorkItem {
//    for i in 1..<6 {
//        print("two\(i)")
//        guard let item = workItem, !item.isCancelled else {
//            print("cancelled")
//            break
//        }
//        print(String(i))
//    }
//}
//
//workItem?.notify(queue: .main) {
//    print("done")
//}
//
//DispatchQueue.global().async {
//    print("one")
//    workItem?.cancel()
//}
//
//print("fucking two")
//DispatchQueue.main.async(execute: workItem!)
//print("fucking three")
//workItem!.wait()
//print("fucking four")
//sleep(2)
//print("fucking five")
//
//// you can use perform to run on the current queue instead of queue.async(execute:)
////workItem?.perform()
//
////
//let background = DispatchQueue.global()
//
////func doSyncWork() {
////    background.sync { for _ in 1...3 { print("Light") } }
////
////    for _ in 1...3 { print("Heavy") }
////}
////
////doSyncWork()
//
//protocol Threadable {
//    func go()
//}
//
//class ThreadStuff: Threadable {
//    let dg = DispatchGroup()
//    var sp: DispatchWorkItem!
//    var ex: DispatchWorkItem!
//
//    func spawn() { for _ in 0..<1000 {print("spawn")} }
//    func execute() { for _ in 0..<1000 {print("execute")} }
//
//    func go() {
//        print(".", terminator: "")
//        sp = DispatchWorkItem(block: self.spawn)
//        ex = DispatchWorkItem(block: self.execute)
//        print("!", terminator: "")
//        dg.enter()
//        spawn()
//        execute()
//        dg.leave()
//    }
//}
//
#if TEMPLATE_THAT_SUPPOSEDLY_WORKS
let group = DispatchGroup()
let queue = DispatchQueue.global()
//let queue = DispatchQueue(label: "com.theswiftdev.queues.serial")
let workItem = DispatchWorkItem {
    print("start")
    //    sleep(1)
    print("end")
}

queue.async(group: group) {
    print("group start")
    //    sleep(2)
    print("group end")
}

queue.async(group: group) { print("fuck this too!") }
queue.async(group: group, execute: workItem)

// you can block your current queue and wait until the group is ready
// a better way is to use a notification block instead of blocking
//group.wait(timeout: .now() + .seconds(3))
//print("done")

group.notify(queue: queue) {
    print("done")
}
sleep(1)
#endif

#if true

//typealias Genome = String


//class FTFitnessTester {
//    let id: Int
//    let dg: DispatchGroup
//    let dq: DispatchQueue
//    var sp: DispatchWorkItem!
//
//    init(_ id: Int, dg: DispatchGroup, dq: DispatchQueue) {
//        self.id = id
//        self.dg = dg
//        self.dq = dq
//    }
//
//    func go() {
//        sp = DispatchWorkItem(block: self.spawn)
//        dq.async(execute: sp)
//    }
//
//    func spawn() {
//        print("FT \(id) spawning")
//    }
//}
//
//let dq = DispatchQueue.global()
//let dg = DispatchGroup()
//var testers = [FTFitnessTester]()
//
//for fishNumber in 0..<10 {
//    let ft = FTFitnessTester(fishNumber, dg: dg, dq: dq)
//    testers.append(ft)
//    ft.go()
//}
//
//dg.notify(queue: dq) { print("close?") }
//
//print("hell")
//dg.wait()
//print("5h34")
//sleep(1)
#endif
//print("a", terminator: "")
////let ts = ThreadStuff()
////print("b", terminator: "")
////ts.go()
////print("c", terminator: "")
//////print("gone")
//////ts.dg.wait()
//////ts.dg.notify(queue: background, execute: {print("how about this?") })
////print("d", terminator: "")
//////ts.dg.notify(queue: background, work: ts.ex)
