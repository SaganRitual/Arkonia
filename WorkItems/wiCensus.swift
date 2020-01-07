import SpriteKit

extension WorkItems {
    typealias OnComplete1Fishday = (Fishday) -> Void

    static func registerBirth(
        myName: String, myParent: Stepper?, _ onComplete: @escaping OnComplete1Fishday
    ) {
        Census.dispatchQueue.async(flags: .barrier) {
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
        Census.dispatchQueue.async(flags: .barrier) {
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
        func b() { getNames(portal)           { names = $0; c() } }
        func c() { getAges(names, worldClock) { ages = $0; d() } }

        func d() {
            seedWorld(ages)
            Census.shared.updateReports(ages)
        }

        a()
    }

    private static func getAges(
        _ names: [String], _ currentTime: Int, _ onComplete: @escaping OnCompleteIntArray
    ) {
        Census.dispatchQueue.async(flags: .barrier) {
            let ages = names.map { Census.getAge(of: $0, at: currentTime) }
            onComplete(ages)
        }
    }

    static func getNames(
        _ portal: SKSpriteNode, _ onComplete: @escaping OnCompleteStringArray
    ) {
        var names = [String]()

        let action = SKAction.run {
            names = portal.children.compactMap { node in
                (node as? SKSpriteNode)?.getStepper(require: false)?.name
            }
        }

        portal.run(action) { onComplete(names) }
    }

//    static let targetCArkons = 50
//    static var cArkons = 0
//    static var populated = false
//    static func seedWorld(_ ages: [Int]) {
//        if populated == false {
//            Dispatch().spawn()
//            cArkons += 1
//            populated = (cArkons >= targetCArkons)
//        }
//    }

    static var populated = false
    static func seedWorld(_ ages: [Int]) {
        if populated == false {
            for _ in 0..<Arkonia.initialPopulation { Dispatch().spawn() }
            populated = true
        }
    }
}
