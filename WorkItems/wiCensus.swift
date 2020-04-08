import SpriteKit

extension WorkItems {
    typealias OnComplete1Fishday = (Fishday) -> Void

    static func registerBirth(
        myName: ArkonName, myParent: Stepper?, myNet: Net?, _ onComplete: @escaping OnComplete1Fishday
    ) {
        Census.dispatchQueue.async {
            let fishday = Census.shared.registerBirth(myName, myParent, myNet)
            onComplete(fishday)
        }
    }

    static func registerDeath(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        var worldClock = 0

        func a() { Clock.getWorldClock { worldClock = $0; b() } }
        func b() { registerDeath(stepper.name, stepper.net!.cNeurons, worldClock, onComplete) }

        a()
    }

    static func registerDeath(
        _ nameOfDeceased: ArkonName, _ cNeuronsOfDeceased: Int, _ worldTime: Int, _ onComplete: @escaping () -> Void
    ) {
        Census.dispatchQueue.async {
            Census.shared.registerDeath(nameOfDeceased, cNeuronsOfDeceased, worldTime)
            onComplete()
        }
    }

}

extension WorkItems {
    typealias OnComplete1p = (Int) -> Void
    typealias OnCompleteIntArray = ([Int]) -> Void
    typealias OnCompleteStringArray = ([String]) -> Void

    static func updateReports() {
        guard let portal = GriddleScene.arkonsPortal else { fatalError() }

        var ages = [Int]()
        var names = [ArkonName]()
        var worldClock = 0

        func a() { Clock.getWorldClock              { worldClock = $0; b() } }

        func b() { getNames(portal)           { names.append(contentsOf: $0); c() } }
        func c() { getAges(names, worldClock) { ages = $0; d() } }

        func d() {
            seedWorld()
            Census.shared.updateReports(ages, worldClock)
        }

        a()
    }

    private static func getAges(
        _ names: [ArkonName], _ currentTime: Int, _ onComplete: @escaping OnCompleteIntArray
    ) {
        Census.dispatchQueue.async {
            let ages = names.map({ Census.getAge(of: $0, at: currentTime) }).sorted()
            onComplete(ages)
        }
    }

    static func getNames(
        _ portal: SKSpriteNode, _ onComplete: @escaping ([ArkonName]) -> Void
    ) {
        var names: [ArkonName]!

        func a() { Census.dispatchQueue.async(execute: b) }

        func b() { names = Census.shared.archive.keys.filter { $0 != ArkonName.empty }; c() }

        // I don't recall why I'm calling onComplete on the scene dispatch; look into it
        func c() { SceneDispatch.shared.schedule { onComplete(names) } }

        a()
    }

    static var populated = false
    static func seedWorld() {
        if populated == false {
            for _ in 0..<Arkonia.initialPopulation { Dispatch().spawn() }
            populated = true
        }
    }
}
