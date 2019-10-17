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
        self.stepper!.arrive {
            if let victor = $0, let victim = $1 {
                victor.coordinator.parasitize(victim)
                victim.coordinator.apoptosize()
            }

            self.funge()
        }
    }

    func apoptosize() {
        self.stepper?.apoptosize()
    }

    func colorize() {
        World.shared.getCurrentTime { [unowned self] currentTime in
            let myAge = currentTime - self.core.selectoid.birthday

            self.core.colorize(
                metabolism: self.metabolism, age: myAge, completion: self.shiftStart
            )
        }

    }

    func cspawn() {
        guard let st = self.stepper else { fatalError() }
        let cs = CSpawn(st, goParent: metabolize(_:), goOffspring: funge(_:))
        cs.spawnIf()
    }

    func dead() {

    }

    func funge() {
        World.shared.getCurrentTime { [unowned self] currentTime in
            let myAge = currentTime - self.core.selectoid.birthday
            self.metabolism.funge(myAge, alive: self.cspawn, dead: self.apoptosize)
        }
    }

    func funge(_ who: Stepper) { who.coordinator.funge() }

    func metabolize(_ who: Stepper) {
        who.metabolism.metabolize(completion: colorize)
    }

    func parasitize(_ victim: Stepper) {
        metabolism.parasitize(victim.metabolism, completion: funge)
    }

    func shiftCalculate() {

        guard let ss = self.shift else { fatalError() }
        guard let st = self.stepper else { fatalError() }

        ss.calculateShift(
            from: st.gridlet,
            previousShift: st.previousShift,
            setShiftTarget: setShiftTarget,
            completion: shiftShift
        )
    }

    func shiftShift() {
        self.shift!.shift(whereIAmNow: self.stepper!.gridlet) { [weak self] in
            guard let myself = self else { print("Bail in shiftShift()"); return }
            myself.shift = nil
            myself.arrive()
        }
    }

    func shiftStart() {
        guard let st = self.stepper else { fatalError() }

        self.shift = Shift(stepper: st)
        self.shift!.start(st.gridlet, completion: shiftCalculate)
    }
}

extension Coordinator {
    func setShiftTarget(_ shiftTarget: AKPoint) {
        print("setShiftTarget(\(shiftTarget))")
        stepper!.shiftTarget = shiftTarget
    }
}
