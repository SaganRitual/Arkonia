import SpriteKit

typealias CoordinatorCallback = () -> Void
typealias ShiftTargetCallback = (AKPoint) -> Void
typealias StepperSimpleCallback = (Stepper) -> Void
typealias StepperDoubleCallback = (Stepper?, Stepper?) -> Void

class Coordinator {
    var core: Arkon { return stepper!.core }
    var metabolism: Metabolism { return stepper!.metabolism }
    var racing = "was <nothing>"
    var shift: Shift?
    weak var stepper: Stepper?

    init(stepper: Stepper) { self.stepper = stepper }

    deinit {
        shift = nil
    }
}

extension Coordinator {

    func arrive() {
//        print("a(\(stepper?.core.selectoid.fishNumber ?? -1))")
        self.stepper!.arrive { [unowned self] in
//            print("n(\(self.stepper!.core.selectoid.fishNumber))")
            if let victor = $0, let victim = $1 {
                victor.coordinator.parasitize(victim)
                victim.coordinator.apoptosize()
            }

            self.funge()
        }
    }

    func apoptosize() {
//        print("b(\(stepper?.core.selectoid.fishNumber ?? -1))")
        self.stepper?.apoptosize()
    }

    func colorize() {
//        print("c(\(stepper?.core.selectoid.fishNumber ?? -1))")
        World.shared.getCurrentTime { [unowned self] currentTime in
            let myAge = currentTime - self.core.selectoid.birthday

            self.core.colorize(
                metabolism: self.metabolism, age: myAge, completion: self.shiftStart
            )
        }

    }

    func cspawn() {
//        print("d(\(stepper?.core.selectoid.fishNumber ?? -1))")
        guard let st = self.stepper else { fatalError() }
        let cs = CSpawn(st, goParent: metabolize(_:), goOffspring: funge(_:))
        cs.spawnIf()
    }

    func dead() {
//        print("e(\(stepper?.core.selectoid.fishNumber ?? -1))")
    }

    func funge() {
//        print("ftf?")
//        print("f(\(stepper?.core.selectoid.fishNumber ?? -1))")
        World.shared.getCurrentTime { [unowned self] currentTime in
//            print("O(\(self.stepper!.core.selectoid.fishNumber))")
            let myAge = currentTime - self.core.selectoid.birthday
            self.metabolism.funge(myAge, alive: self.cspawn, dead: self.apoptosize)
//            print("P(\(self.stepper!.core.selectoid.fishNumber))")
        }
    }

    func funge(_ who: Stepper) {
//        print("g(\(stepper?.core.selectoid.fishNumber ?? -1))")
        who.coordinator.funge() }

    func metabolize(_ who: Stepper) {
//        print("h(\(stepper?.core.selectoid.fishNumber ?? -1))")
        who.metabolism.metabolize(completion: colorize)
    }

    func parasitize(_ victim: Stepper) {
//        print("i(\(stepper?.core.selectoid.fishNumber ?? -1))")
        metabolism.parasitize(victim.metabolism, completion: funge)
    }

    func shiftCalculate() {
//        print("j(\(stepper?.core.selectoid.fishNumber ?? -1))")

        guard let ss = self.shift else { fatalError() }
        guard let st = self.stepper else { fatalError() }
//        print("k(\(stepper?.core.selectoid.fishNumber ?? -1))")

        ss.calculateShift(
            from: st.gridlet,
            previousShift: st.previousShift,
            setShiftTarget: setShiftTarget,
            completion: shiftShift
        )
    }

    func shiftShift() {
//        print("L(\(stepper?.core.selectoid.fishNumber ?? -1))")
        self.shift!.shift(whereIAmNow: self.stepper!.gridlet) { [weak self] in
            guard let myself = self else { print("Bail in shiftShift()"); return }
//            print("m(\(self!.stepper!.core.selectoid.fishNumber))")
            myself.shift = nil
            myself.arrive()
        }
    }

    func shiftStart() {
//        print("M(\(stepper?.core.selectoid.fishNumber ?? -1))")
        guard let st = self.stepper else { fatalError() }

        self.shift = Shift(stepper: st)
        self.shift!.start(st.gridlet, completion: shiftCalculate)
    }
}

extension Coordinator {
    func setShiftTarget(_ shiftTarget: AKPoint) {
//print("N(\(stepper?.core.selectoid.fishNumber ?? -1))")
//        print("setShiftTarget(\(shiftTarget))")
        stepper!.shiftTarget = shiftTarget
    }
}
