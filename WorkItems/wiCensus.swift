import SpriteKit

extension WorkItems {
    typealias OnComplete1Fishday = (Fishday) -> Void

    static func registerBirth(
        myName: String, myParent: Stepper?, _ onComplete: @escaping OnComplete1Fishday
    ) {
        Census.dispatchQueue.async {
            let fishday = Census.shared.registerBirth(myName, myParent)
            onComplete(fishday)
        }
    }

    static func registerDeath(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        var worldClock = 0

        func a() { getWorldClock { worldClock = $0; b() } }
        func b() { registerDeath(stepper.name, worldClock, onComplete) }

        a()
    }

    static func registerDeath(
        _ nameOfDeceased: String, _ worldTime: Int, _ onComplete: @escaping () -> Void
    ) {
        Census.dispatchQueue.async {
            Census.shared.registerDeath(nameOfDeceased, worldTime)
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
        var names = [String]()
        var worldClock = 0

        func a() { getWorldClock              { worldClock = $0; b() } }

        // append here because grasping for straws at the cause of this
        // weird data race
        func b() { getNames(portal)           { names.append(contentsOf: $0); c() } }
        func c() { getAges(names, worldClock) { ages = $0; d() } }

        func d() {
            seedWorld()
            Census.shared.updateReports(ages, worldClock)
        }

        a()
    }

    private static func getAges(
        _ names: [String], _ currentTime: Int, _ onComplete: @escaping OnCompleteIntArray
    ) {
        Census.dispatchQueue.async {
            let ages = names.map({ Census.getAge(of: $0, at: currentTime) }).sorted()
            onComplete(ages)
        }
    }

    static func getNames(
        _ portal: SKSpriteNode, _ onComplete: @escaping OnCompleteStringArray
    ) {
        SceneDispatch.schedule {
            Debug.log(level: 102) { "getNames" }
            let names = portal.children.compactMap { $0.name }
            onComplete(names)
        }
    }

    static var populated = false
    static func seedWorld() {
        if populated == false {
            for _ in 0..<Arkonia.initialPopulation { Dispatch().spawn() }
            populated = true
        }
    }
}
