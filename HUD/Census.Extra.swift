import SpriteKit

extension Census {
    typealias OnComplete1Fishday = (Fishday) -> Void

    static func registerBirth(
        myName: ArkonName, myParent: Stepper?, myNet: Net, _ onComplete: @escaping OnComplete1Fishday
    ) {
        Census.dispatchQueue.async {
            let fishday = Census.shared.registerBirth(myName, myParent, myNet)
            onComplete(fishday)
        }
    }

    static func registerDeath(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        var worldClock = 0

        func a() { Clock.getWorldClock { worldClock = $0; b() } }
        func b() { registerDeath(stepper, worldClock, onComplete) }

        a()
    }

    static func registerDeath(
        _ stepper: Stepper, _ worldTime: Int, _ onComplete: @escaping () -> Void
    ) {
        Census.dispatchQueue.async {
            Census.shared.registerDeath(stepper, worldTime)
            onComplete()
        }
    }

}

extension Census {
    func updateReports() {
        let portal = ArkoniaScene.arkonsPortal!

        var ages = [Int]()
        var worldClock = 0

        func a() { getAges { ages = $0; worldClock = $1; b() } }

        func b() {
            seedWorld()
            Census.shared.updateReports(worldClock)
        }

        a()
    }

    func getAges(_ onComplete: @escaping ([Int], Int) -> Void) {
//        let portal = (ArkoniaScene.arkonsPortal)!
//
//        var names = [ArkonName]()
//        var worldClock = 0
//
//        func a() { Clock.getWorldClock        { worldClock = $0; b() } }
//
//        func b() { getNames(portal)           { names.append(contentsOf: $0); c() } }
//        func c() {
//            getAges(names, worldClock) { onComplete($0, worldClock) }
//        }
//
//        a()
        onComplete([0], 0)
    }

    private func getAges(
        _ names: [ArkonName], _ currentTime: Int, _ onComplete: @escaping ([Int]) -> Void
    ) {
//        Census.dispatchQueue.async {
//            let ages = names.compactMap({ Census.getAge(of: $0, at: currentTime) }).sorted()
//            onComplete(ages)
//        }
        onComplete([0])
    }

    func getNames(
        _ portal: SKSpriteNode, _ onComplete: @escaping ([ArkonName]) -> Void
    ) {
//        var names: [ArkonName]!
//
//        func a() { Census.dispatchQueue.async(execute: b) }
//
//        func b() { names = Census.shared.archive.keys.map { $0 }; c() }
//
//        // I don't recall why I'm calling onComplete on the scene dispatch; look into it
//        func c() { SceneDispatch.shared.schedule { onComplete(names) } }
//
//        a()
        onComplete([ArkonName.empty])
    }

    func seedWorld() {
        if populated == false {
            if Arkonia.debugGrid { Ingrid.shared.sprites.drawGridIndicators() }
            else { for _ in 0..<Arkonia.initialPopulation { Dispatch().spawn() } }

            populated = true
        }
    }
}
