import SpriteKit

typealias CoordinatorCallback = () -> Void
typealias ShiftTargetCallback = (AKPoint) -> Void
typealias StepperSimpleCallback = (Stepper) -> Void
typealias StepperDoubleCallback = (Stepper?, Stepper?) -> Void

class Coordinator {
    var core: Arkon? { return stepper?.core }
    var metabolism: Metabolism? { return stepper?.metabolism }
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
//            print("n1(\(self.stepper!.core.selectoid.fishNumber))", terminator: "")
            if let victor = $0, let victim = $1 {
                victor.coordinator.parasitize(victim)
                victim.coordinator.apoptosize()
            }
//            print("n2(\(self.stepper!.core.selectoid.fishNumber))", terminator: "")

            self.funge()
//            print("n3(\(self.stepper!.core.selectoid.fishNumber))", terminator: "")
        }
    }

    func apoptosize() {
//        print("b(\(stepper?.core.selectoid.fishNumber ?? -1))")
        self.stepper?.apoptosize()
    }

    func colorize() {
//        print("c(\(stepper?.core.selectoid.fishNumber ?? -1))")
        World.shared.getCurrentTime { [weak self] currentTime in
            guard let myself = self,
                let mycore = myself.core,
                let mymb = myself.metabolism
            else {
//                print("Bailing in colorize")
                return
            }

            let myAge = currentTime - mycore.selectoid.birthday

            mycore.colorize(
                metabolism: mymb, age: myAge, completion: myself.shiftStart
            )
        }

    }

    func cspawn() {
//        print("d(\(stepper?.core.selectoid.fishNumber ?? -1))")
        guard let st = self.stepper else {
//            print("Stepper bailing in cspawn")
            return
        }
        let cs = CSpawn(st, goParent: metabolize(_:), goOffspring: funge(_:))
        cs.spawnIf()
    }

    func dead() {
//        print("e(\(stepper?.core.selectoid.fishNumber ?? -1))")
    }

    func funge() {
//        print("ftf?")
//        print("f(\(stepper?.core.selectoid.fishNumber ?? -1))")
        World.shared.getCurrentTime { [weak self] currentTime in
            guard let myself = self,
                let mycore = myself.core,
                let mymb = myself.metabolism
            else {
//                print("Bailing in funge")
                return
            }
//            print("O(\(self.stepper!.core.selectoid.fishNumber))")
            let myAge = currentTime - mycore.selectoid.birthday
            mymb.funge(myAge, alive: myself.cspawn, dead: myself.apoptosize)
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
        guard let mymb = metabolism, let hismb = victim.metabolism else { return }
        mymb.parasitize(hismb, completion: funge)
    }

    func shiftCalculate() {
//        print("j(\(stepper?.core.selectoid.fishNumber ?? -1))")

        guard let ss = self.shift else {
//            print("Bail1 in shiftCalculate()")
            return }
        guard let st = self.stepper else {
//            print("Bail2 in shiftCalculate()")
            return }
//        print("k(\(stepper?.core.selectoid.fishNumber ?? -1))")

        ss.calculateShift(
            from: st.gridlet,
            previousShift: st.previousShift,
            setShiftTarget: setShiftTarget,
            completion: shiftShift
        )
    }

    func shiftShift() {
        guard let ss = self.shift else {
//            print("Bail1 in shiftShift()")
            return
        }
        guard let st = self.stepper else {
//            print("Bail2 in shiftShift()")
            return
        }

        ss.shift(whereIAmNow: st.gridlet) { [weak self] in
            guard let myself = self else {
//                print("Bail3 in shiftShift()")
                return
            }
            myself.shift = nil
            myself.arrive()
        }
    }

    func shiftStart() {
        guard let st = self.stepper else {
//            print("Bail in shiftStart()")
            return
        }

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
