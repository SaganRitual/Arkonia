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
        self.core.colorize(
            metabolism: metabolism, age: self.core.age, completion: shiftStart
        )
    }

    func cspawn() {
        guard let st = self.stepper else { fatalError() }
        st.cspawn(goParent: metabolize(_:), goOffspring: funge(_:))
    }

    func dead() {

    }

    func funge() {
        self.metabolism.funge(core.age, alive: cspawn, dead: apoptosize)
    }

    func funge(_ who: Stepper) { who.coordinator.funge() }

    func metabolize(_ who: Stepper) {
        who.metabolism.metabolize(completion: colorize)
    }

    func parasitize(_ victim: Stepper) {
        metabolism.parasitize(victim.metabolism, completion: funge)
    }

    func shiftCalculate() {
        self.shift!.calculateShift(
            from: self.stepper!.gridlet,
            previousShift: self.stepper!.previousShift,
            setShiftTarget: setShiftTarget,
            completion: shiftShift
        )
    }

    func shiftShift() {
        self.shift!.shift(whereIAmNow: self.stepper!.gridlet) { [unowned self] in
            self.shift = nil
            self.arrive()
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
        stepper!.shiftTarget = shiftTarget
    }
}
